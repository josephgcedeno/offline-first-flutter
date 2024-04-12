import 'package:flirt/domain/repository/secure_storage_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecureStorageCubit extends Cubit<void> {
  SecureStorageCubit({required this.storage}) : super(null);
  final ISecureStorageRepository storage;

  Future<String?> read({required String key}) async => storage.read(key: key);

  Future<void> write({required String key, required String value}) async =>
      storage.write(key: key, value: value);

  Future<void> delete({required String key}) async => storage.delete(key: key);

  Future<void> clear() async => storage.clear();
}
