import 'package:galleria/src/model.dart';
import 'package:galleria/src/package.dart';
import 'package:galleria/utils/util_functions.dart';
import 'package:galleria/view/screens/dashboard_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //Firebase initialization.
  await UtilFunctions.anonymousAuth();
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);

  Hive.registerAdapter(PhotoModelAdapter());

  await Hive.openBox<PhotoModel>("photosBox");

  // scan Galleria and update Hive
  final galleriaPaths = await UtilFunctions.scanGalleriaAlbum();
  UtilFunctions.updateHiveDbBasedOnPhotosInGallery(galleriaPaths);

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galleria',
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}
