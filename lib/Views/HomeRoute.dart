import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/User.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  final IUserBLL _userBll = UserBll();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solid CV'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'lib/assets/home-background.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.white.withOpacity(0.5),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: UnderlineInputBorder(),
                            ),
                            controller: emailController,
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: UnderlineInputBorder(),
                            ),
                            controller: passwordController,
                            obscureText: true,
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // move to register route
                                  Navigator.pushNamed(context, '/register');
                                }, 
                                child: const Text('Register'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  var user = User();
                                  user.email = emailController.text;
                                  user.password = passwordController.text;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Logging in...')),
                                  );

                                  user = await _userBll.login(user);
                                  const storage = FlutterSecureStorage();
                                  await storage.write(key: 'jwt', value: user.token);
                                  Navigator.pushNamed(context, '/loggedin/home');
                                },
                                child: const Text('Login'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
