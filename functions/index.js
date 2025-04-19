const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

// Configure Gmail SMTP
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "meerabt041@gmail.com",  // Use your email
    pass: "vWzMxEq7rbTW",   // Use an App Password
  },
});

exports.sendDoctorCredentials = functions.https.onCall(async (data, context) => {
  const email = data.email;
  const password = data.password;
  const name = data.name;

  const mailOptions = {
    from: "Tooth Tales <your-email@gmail.com>",
    to: email,
    subject: "Your Dentist Account Credentials",
    html: `
      <h3>Welcome ${name}!</h3>
      <p>Your account has been successfully created.</p>
      <p><b>Email:</b> ${email}</p>
      <p><b>Password:</b> ${password}</p>
      <p>Please verify your email and log in.</p>
      <br>
      <p>Best Regards,</p>
      <p>Tooth Tales Team</p>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true, message: "Email sent successfully" };
  } catch (error) {
    console.error("Email error:", error);
    return { success: false, message: "Failed to send email" };
  }
});
