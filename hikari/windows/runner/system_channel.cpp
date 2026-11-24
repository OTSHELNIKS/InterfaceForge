#include "system_channel.h"

#include <flutter/encodable_value.h>
#include <flutter/method_call.h>
#include <flutter/method_channel.h>
#include <flutter/method_result.h>
#include <flutter/standard_method_codec.h>

#include <windows.h>

#include <string>

namespace hikari {
namespace {

std::string WideToUtf8(const std::wstring& wide) {
  if (wide.empty()) {
    return {};
  }
  const int size = WideCharToMultiByte(CP_UTF8, 0, wide.c_str(),
                                       static_cast<int>(wide.size()), nullptr, 0,
                                       nullptr, nullptr);
  std::string out(static_cast<size_t>(size), 0);
  WideCharToMultiByte(CP_UTF8, 0, wide.c_str(), static_cast<int>(wide.size()),
                      out.data(), size, nullptr, nullptr);
  return out;
}

std::wstring Utf8ToWide(const std::string& utf8) {
  if (utf8.empty()) {
    return {};
  }
  const int size = MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(),
                                       static_cast<int>(utf8.size()), nullptr, 0);
  std::wstring out(static_cast<size_t>(size), 0);
  MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(), static_cast<int>(utf8.size()),
                      out.data(), size);
  return out;
}

std::string ReadRegistryString(HKEY root, const wchar_t* sub_key,
                               const wchar_t* value_name) {
  wchar_t buffer[512] = {0};
  DWORD size = sizeof(buffer);
  if (RegGetValueW(root, sub_key, value_name, RRF_RT_REG_SZ, nullptr, buffer,
                   &size) == ERROR_SUCCESS) {
    return WideToUtf8(buffer);
  }
  return {};
}

bool SetWallpaper(const std::string& utf8_path) {
  std::wstring path = Utf8ToWide(utf8_path);
  if (path.empty()) {
    return false;
  }
  // SystemParametersInfoW копирует строку, поэтому временный буфер безопасен.
  return SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, path.data(),
                               SPIF_UPDATEINIFILE | SPIF_SENDCHANGE) != 0;
}

void WriteDword(const wchar_t* name, DWORD value) {
  HKEY key = nullptr;
  const wchar_t* sub_key =
      L"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize";
  if (RegCreateKeyExW(HKEY_CURRENT_USER, sub_key, 0, nullptr,
                      REG_OPTION_NON_VOLATILE, KEY_SET_VALUE, nullptr, &key,
                      nullptr) != ERROR_SUCCESS) {
    return;
  }
  RegSetValueExW(key, name, 0, REG_DWORD, reinterpret_cast<const BYTE*>(&value),
                 sizeof(value));
  RegCloseKey(key);
}

void SetSystemTheme(bool dark) {
  // 0 — тёмная тема, 1 — светлая ( семантика реестра Windows ).
  const DWORD value = dark ? 0 : 1;
  WriteDword(L"AppsUseLightTheme", value);
  WriteDword(L"SystemUsesLightTheme", value);
}

std::string WindowsVersion() {
  typedef LONG(WINAPI* RtlGetVersionPtr)(PRTL_OSVERSIONINFOW);
  RTL_OSVERSIONINFOW info = {0};
  info.dwOSVersionInfoSize = sizeof(info);
  HMODULE module = GetModuleHandleW(L"ntdll.dll");
  if (module != nullptr) {
    auto rtl_get_version = reinterpret_cast<RtlGetVersionPtr>(
        GetProcAddress(module, "RtlGetVersion"));
    if (rtl_get_version != nullptr && rtl_get_version(&info) == 0) {
      return std::to_string(info.dwMajorVersion) + "." +
             std::to_string(info.dwMinorVersion) + "." +
             std::to_string(info.dwBuildNumber);
    }
  }
  return "Windows";
}

std::string DeviceModel() {
  const std::string manufacturer =
      ReadRegistryString(HKEY_LOCAL_MACHINE, L"HARDWARE\\DESCRIPTION\\System\\BIOS",
                         L"SystemManufacturer");
  const std::string product =
      ReadRegistryString(HKEY_LOCAL_MACHINE, L"HARDWARE\\DESCRIPTION\\System\\BIOS",
                         L"SystemProductName");
  if (manufacturer.empty() && product.empty()) {
    return "PC";
  }
  if (manufacturer.empty()) {
    return product;
  }
  if (product.empty()) {
    return manufacturer;
  }
  return manufacturer + " " + product;
}

}  // namespace

void RegisterSystemChannel(flutter::BinaryMessenger* messenger) {
  static flutter::MethodChannel<flutter::EncodableValue> channel(
      messenger, "hikari/system", &flutter::StandardMethodCodec::GetInstance());

  channel.SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        const std::string& method = call.method_name();

        if (method == "getDeviceInfo") {
          flutter::EncodableMap info;
          info[flutter::EncodableValue(std::string("platform"))] =
              flutter::EncodableValue(std::string("Windows"));
          info[flutter::EncodableValue(std::string("version"))] =
              flutter::EncodableValue(WindowsVersion());
          info[flutter::EncodableValue(std::string("model"))] =
              flutter::EncodableValue(DeviceModel());
          info[flutter::EncodableValue(std::string("wallpaperSupported"))] =
              flutter::EncodableValue(true);
          result->Success(flutter::EncodableValue(info));
          return;
        }

        if (method == "applyWallpaper") {
          const auto* path = std::get_if<std::string>(call.arguments());
          if (path == nullptr) {
            result->Error("bad_args", "Путь к обоям обязателен");
            return;
          }
          if (SetWallpaper(*path)) {
            result->Success(flutter::EncodableValue(true));
          } else {
            result->Error("wallpaper_failed",
                          "SystemParametersInfo не смог установить обои");
          }
          return;
        }

        if (method == "applyTheme") {
          bool dark = false;
          const auto* args =
              std::get_if<flutter::EncodableMap>(call.arguments());
          if (args != nullptr) {
            const auto it = args->find(flutter::EncodableValue(std::string("dark")));
            if (it != args->end()) {
              const auto* value = std::get_if<bool>(&it->second);
              if (value != nullptr) {
                dark = *value;
              }
            }
          }
          SetSystemTheme(dark);
          flutter::EncodableMap response;
          response[flutter::EncodableValue(std::string("applied"))] =
              flutter::EncodableValue(true);
          response[flutter::EncodableValue(std::string("system"))] =
              flutter::EncodableValue(true);
          result->Success(flutter::EncodableValue(response));
          return;
        }

        if (method == "resetSystemTheme") {
          SetSystemTheme(false);
          result->Success(flutter::EncodableValue(true));
          return;
        }

        result->NotImplemented();
      });
}

}  // namespace hikari
