import '../repositories/user_repository.dart';

/// Helper class to seed default users
class UserSeedHelper {
  static final UserRepository _userRepository = UserRepository();

  /// Create admin user if it doesn't exist
  static Future<void> createAdminIfNeeded() async {
    try {
      // Check if admin exists
      final existingAdmin = await _userRepository.getUserByEmail('admin@edupalestine.com');
      
      if (existingAdmin == null) {
        print('🔐 Creating admin user...');
        
        final admin = await _userRepository.createUser(
          email: 'admin@edupalestine.com',
          password: 'admin123',
          firstName: 'Admin',
          lastName: 'EduPalestine',
          role: 'admin',
        );
        
        print('✅ Admin user created successfully');
        print('   Email: admin@edupalestine.com');
        print('   Password: admin123');
        print('   ID: ${admin.id}');
      } else {
        print('✅ Admin user already exists (ID: ${existingAdmin.id})');
      }
    } catch (e) {
      print('❌ Error creating admin user: $e');
    }
  }

  /// Create test users if needed
  static Future<void> createTestUsersIfNeeded() async {
    try {
      // Create admin
      await createAdminIfNeeded();
      
      // Check if test user exists
      final existingTest = await _userRepository.getUserByEmail('ilyes@test.com');
      
      if (existingTest == null) {
        print('🔐 Creating test user...');
        
        final testUser = await _userRepository.createUser(
          email: 'ilyes@test.com',
          password: 'password123',
          firstName: 'Ilyes',
          lastName: 'Test',
          role: 'student',
        );
        
        print('✅ Test user created successfully');
        print('   Email: ilyes@test.com');
        print('   Password: password123');
        print('   ID: ${testUser.id}');
      } else {
        print('✅ Test user already exists (ID: ${existingTest.id})');
      }
    } catch (e) {
      print('❌ Error creating test users: $e');
    }
  }
}
