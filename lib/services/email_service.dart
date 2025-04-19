import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static Future<void> sendEmail({
    required String recipientEmail,
    required String recipientName,
    required String password,
  }) async {
    // **Replace with your Gmail and App Password**
    String senderEmail = "meerabt041@gmail.com";
    String senderPassword = "fqrj tprw rtrc spaq";

    // **Set up SMTP Server**
    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      username: senderEmail,
      password: senderPassword,
      port: 587,  // Use 465 for SSL or 587 for TLS
      ssl: false,
      allowInsecure: true,
    );

    // **Create Email Message**
    final message = Message()
      ..from = Address(senderEmail, "Team Dental Wellness")
      ..recipients.add(recipientEmail)
      ..subject = "Your Dentist Account Credentials"
      ..html = """
        <h3>Welcome Dr. $recipientName!</h3>
        <p>Your dentist account has been successfully created.</p>
        <p><b>Email:</b> $recipientEmail</p>
        <p><b>Password:</b> $password</p>
        <p><i>Please verify your email before logging in.</i></p>
        <br>
        <p>Best Regards,</p>
        <p><b>Dental Wellness Team</b></p>
      """;

    try {
      // **Send the email**
      await send(message, smtpServer);
      print("✅ Email sent successfully to $recipientEmail");
    } catch (e) {
      print("❌ Failed to send email: $e");
    }
  }
}
