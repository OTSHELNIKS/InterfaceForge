import 'package:web/web.dart' as web;

Future<bool> downloadPreview(String asset, String filename) async {
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = Uri.base.resolve('assets/$asset').toString();
  anchor.download = filename;
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  return true;
}
