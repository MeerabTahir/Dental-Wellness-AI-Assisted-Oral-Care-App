import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tooth_tales/screens/admin/adminhomepage.dart';
import 'package:tooth_tales/screens/article/article.dart';
import 'package:tooth_tales/screens/ChatsAndTips/chat.dart';
import 'package:tooth_tales/screens/doctor/doctorProfile.dart';
import 'package:tooth_tales/screens/doctor/dentistQuery.dart';
import 'package:tooth_tales/screens/admin/doctorregisterpage.dart';
import 'package:tooth_tales/screens/admin/manageusers.dart';
import 'package:tooth_tales/screens/admin/managedoctor.dart';
import 'package:tooth_tales/screens/user/patientProfile.dart';
import 'package:tooth_tales/screens/admin/ViewAppointments.dart';
import 'package:tooth_tales/screens/user/schedule.dart';
import 'package:tooth_tales/screens/footer.dart';
import 'package:tooth_tales/screens/user/desc.dart';
import 'package:tooth_tales/screens/user/doctor.dart';
import 'package:tooth_tales/screens/user/appointment.dart';
import 'package:tooth_tales/screens/user/oralexamination.dart';
import 'package:tooth_tales/screens/user/userQuery.dart';
import 'package:tooth_tales/screens/login.dart';

Map<String, WidgetBuilder> appRoutes = {
  '/footer': (context) => FooterScreen(),
  '/doctor': (context) => DoctorScreen(),
  '/schedule': (context) => ScheduleScreen(),
  '/chat': (context) => ChatScreen(),
  '/articles': (context) => ArticleListScreen(),
  'patient_profile': (context) => ProfilePage(),
  '/doctor-profile': (context) => DoctorProfilePage(),
  '/adminhomepage': (context) => AdminHomePage(adminId: "9zMrY7yPCFfQW3mG88cz47MlZau2"),
  '/doctorregisterpage': (context) => DoctorRegisterPage(),
  '/manageusers': (context) => ManageUsersPage(),
  '/managedoctor': (context) => ManageDoctorsPage(),
  '/viewappointments': (context) => ViewAppointmentsPage(),
  '/oralexamination' : (context) => OralExaminationScreen(),
  '/questions': (context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return UserQuery(userId: user.uid);
    } else {
      return LoginScreen();
    }
  },
  '/dentist-queries': (context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return DentistQuery(dentistId: user.uid);
    } else {
      return LoginScreen();
    }
  },


};

Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/desc':
      final args = settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('doctorId')) {
        return MaterialPageRoute(
          builder: (context) => DescriptionScreen(
            doctorId: args['doctorId'],
          ),
        );
      }
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Error: Missing doctorId argument'),
          ),
        ),
      );

    case '/appointment':
      final args = settings.arguments as Map<String, dynamic>?;
      if (args != null &&
          args.containsKey('doctorId') &&
          args.containsKey('selectedSlot')) {
        return MaterialPageRoute(
          builder: (context) => AppointmentScreen(
            doctorId: args['doctorId'],
            selectedSlot: args['selectedSlot'],
          ),
        );
      }
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Error: Missing doctorData or selectedSlot argument'),
          ),
        ),
      );

    default:
      return null;
  }
}
