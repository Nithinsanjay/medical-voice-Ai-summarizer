class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
