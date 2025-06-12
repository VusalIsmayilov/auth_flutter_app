#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

void main() async {
  print('📧 Email Service Configuration Setup');
  print('=' * 50);
  
  final setup = EmailServiceSetup();
  await setup.run();
}

class EmailServiceSetup {
  late String choice;
  late Map<String, String> config;
  
  Future<void> run() async {
    print('Choose your email service provider:');
    print('1. SendGrid (Recommended)');
    print('2. Gmail SMTP');
    print('3. Keep simulation mode (for testing only)');
    print('');
    
    stdout.write('Enter your choice (1-3): ');
    choice = stdin.readLineSync() ?? '3';
    
    switch (choice) {
      case '1':
        await setupSendGrid();
        break;
      case '2':
        await setupGmailSMTP();
        break;
      case '3':
        await setupSimulation();
        break;
      default:
        print('Invalid choice. Keeping simulation mode.');
        await setupSimulation();
    }
    
    await updateConfigurationFiles();
    await showNextSteps();
  }
  
  Future<void> setupSendGrid() async {
    print('');
    print('🚀 SendGrid Setup');
    print('================');
    
    print('1. Go to https://sendgrid.com/ and create a free account');
    print('2. Go to Settings → API Keys → Create API Key');
    print('3. Choose "Restricted Access" with "Mail Send: Full Access"');
    print('4. Copy the API key (starts with "SG.")');
    print('');
    
    stdout.write('Enter your SendGrid API Key: ');
    final apiKey = stdin.readLineSync() ?? '';
    
    if (!apiKey.startsWith('SG.')) {
      print('⚠️  Warning: API key should start with "SG."');
    }
    
    stdout.write('Enter your sender email (e.g., noreply@yourdomain.com): ');
    final fromEmail = stdin.readLineSync() ?? 'noreply@localhost.dev';
    
    stdout.write('Enter sender name (e.g., AuthService): ');
    final fromName = stdin.readLineSync() ?? 'AuthService';
    
    config = {
      'Provider': 'SendGrid',
      'SendGridApiKey': apiKey,
      'FromEmail': fromEmail,
      'FromName': fromName,
      'BaseUrl': 'http://localhost:80'
    };
    
    print('');
    print('✅ SendGrid configuration prepared!');
    print('⚠️  Remember to verify your sender email in SendGrid dashboard!');
  }
  
  Future<void> setupGmailSMTP() async {
    print('');
    print('📧 Gmail SMTP Setup');
    print('==================');
    
    print('1. Enable 2-Factor Authentication on your Google account');
    print('2. Go to Security → App passwords');
    print('3. Generate app password for "Mail"');
    print('4. Copy the 16-character password');
    print('');
    
    stdout.write('Enter your Gmail address: ');
    final username = stdin.readLineSync() ?? '';
    
    stdout.write('Enter your app password (16 characters): ');
    final password = stdin.readLineSync() ?? '';
    
    stdout.write('Enter sender name (e.g., AuthService): ');
    final fromName = stdin.readLineSync() ?? 'AuthService';
    
    config = {
      'Provider': 'SMTP',
      'SmtpHost': 'smtp.gmail.com',
      'SmtpPort': '587',
      'SmtpUsername': username,
      'SmtpPassword': password,
      'FromEmail': username,
      'FromName': fromName,
      'EnableSsl': 'true',
      'BaseUrl': 'http://localhost:80'
    };
    
    print('');
    print('✅ Gmail SMTP configuration prepared!');
  }
  
  Future<void> setupSimulation() async {
    print('');
    print('🧪 Simulation Mode');
    print('==================');
    print('Emails will be logged to console instead of sent.');
    print('This is good for testing the API without real email delivery.');
    
    config = {
      'Provider': 'Simulation',
      'SendGridApiKey': '',
      'FromEmail': 'noreply@localhost.dev',
      'FromName': 'AuthService Development'
    };
    
    print('✅ Simulation mode configured!');
  }
  
  Future<void> updateConfigurationFiles() async {
    print('');
    print('📝 Updating Configuration Files...');
    
    // Generate configuration JSON
    final emailConfig = generateEmailConfig();
    
    print('');
    print('📄 Configuration to add to your appsettings.json:');
    print('=' * 50);
    print('Replace the "Email" section with:');
    print('');
    print(emailConfig);
    print('');
    
    // Write to a file for easy copying
    final configFile = File('email_configuration.json');
    await configFile.writeAsString(emailConfig);
    
    print('💾 Configuration saved to: email_configuration.json');
    print('   You can copy-paste this into your appsettings.json file');
  }
  
  String generateEmailConfig() {
    final encoder = JsonEncoder.withIndent('    ');
    return encoder.convert({'Email': config});
  }
  
  Future<void> showNextSteps() async {
    print('');
    print('🎯 Next Steps:');
    print('=' * 30);
    
    if (choice == '1') {
      print('1. ✅ Complete SendGrid sender verification:');
      print('   - Go to SendGrid Dashboard → Settings → Sender Authentication');
      print('   - Click "Verify a Single Sender"');
      print('   - Use email: ${config['FromEmail']}');
      print('   - Check your email and click verification link');
      print('');
    }
    
    print('2. 📝 Update your backend configuration:');
    print('   - Open: /Users/vusalismayilov/Documents/asp.net_services/AuthService/appsettings.json');
    print('   - Replace the "Email" section with the configuration above');
    print('   - Also update appsettings.Development.json if needed');
    print('');
    
    print('3. 🔄 Restart your backend server:');
    print('   cd /Users/vusalismayilov/Documents/asp.net_services/AuthService');
    print('   dotnet run');
    print('');
    
    print('4. 🧪 Test email verification:');
    print('   - Use Flutter app to register a new user');
    print('   - Check your email inbox for verification email');
    print('   - Complete the verification flow');
    print('');
    
    if (choice == '1') {
      print('5. 📊 Monitor SendGrid activity:');
      print('   - Go to SendGrid Dashboard → Activity');
      print('   - View email delivery status');
      print('');
    }
    
    print('🎉 Your email service will be fully functional once these steps are complete!');
  }
}