import 'package:finance_monitor/core/shared_preference.dart';
import 'package:finance_monitor/presentation/auth/auth_service.dart';
import 'package:finance_monitor/presentation/auth/login_screen.dart';
import 'package:finance_monitor/presentation/home/add_data.dart';
import 'package:finance_monitor/presentation/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedValue = 0;
  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Builder(
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Finance Monitor',
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              GestureDetector(
                onTap: () async {
                  await SharedPrefHelper.setLoginStatus(true);
                  await auth.signout();
                  goToLogin(context);
                },
                child: const Icon(Icons.logout),
              ),
              const SizedBox(
                width: 20,
              )
            ],
          ),
          body: Consumer<HomeViewModel>(
            builder: (context, homeVM, child) {
              return homeVM.data.isNotEmpty
                  ? ListView.builder(
                      itemCount: homeVM.data.length,
                      itemBuilder: (BuildContext context, index) {
                        var value = homeVM.data[index];
                        var data = value['type'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 1.0,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        value['date'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "₹ ",
                                              style: TextStyle(
                                                color: data == 0
                                                    ? Colors.red
                                                    : Colors.lightGreen,
                                              ),
                                            ),
                                            TextSpan(
                                              text: value['amount'].toString(),
                                              style: TextStyle(
                                                color: data == 0
                                                    ? Colors.red
                                                    : Colors.lightGreen,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    thickness: 0.3,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.20,
                                        child: Text(
                                          value['category'],
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          value['note'].toString(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text('No data found'),
                    );
            },
          ),
          floatingActionButton: Consumer<HomeViewModel>(
            builder: (context, homeVM, child) {
              return FloatingActionButton(
                onPressed: () {
                  homeVM.clearFields();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 1000),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const AddDataScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                            position: offsetAnimation, child: child);
                      },
                    ),
                  );
                },
                child: const Icon(Icons.add),
              );
            },
          ),
        );
      },
    );
  }

  goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
}
