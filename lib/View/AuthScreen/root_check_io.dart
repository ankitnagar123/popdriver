import 'dart:io';

Future<bool> checkRootPathsExist() async {
  const rootPaths = [
    '/system/xbin/su',
    '/system/bin/su',
    '/system/sd/xbin/su',
    '/system/bin/failsafe/su',
    '/data/local/su',
    '/sbin/su',
    '/system/app/Superuser.apk',
    '/system/xbin/daemonsu',
  ];

  for (final path in rootPaths) {
    if (await File(path).exists()) {
      return true;
    }
  }
  return false;
}
