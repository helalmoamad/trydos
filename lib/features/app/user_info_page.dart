import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({Key? key}) : super(key: key);

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  Map<String, dynamic>? _savedUserInfo;

  @override
  void initState() {
    super.initState();
    // لا داعي لأي تايمر هنا، التايمر المركزي في BasePage
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onSubmit() async {
    try {
      final Map<String, dynamic> userInfo = _controller.text.isNotEmpty
          ? Map<String, dynamic>.from(userInfoFromJson(_controller.text))
          : {};
      final prefsRepository = GetIt.I<PrefsRepository>();
      // تخزين كل القيم الموجودة في userInfo في prefsRepository
      if (userInfo.containsKey('userMarketId')) {
        prefsRepository.setMyMarketId(userInfo['userMarketId']);
      }
      if (userInfo.containsKey('userMarketToken')) {
        prefsRepository.setMarketToken(userInfo['userMarketToken']);
      }
      if (userInfo.containsKey('userMarketName')) {
        prefsRepository.setMyMarketName(userInfo['userMarketName']);
      }
      if (userInfo.containsKey('userMarketPhone')) {
        prefsRepository.setPhoneNumber(userInfo['userMarketPhone']);
      }
      if (userInfo.containsKey('userChatId')) {
        prefsRepository
            .setMyChatId(int.tryParse(userInfo['userChatId'].toString()) ?? 0);
      }
      if (userInfo.containsKey('userChatToken')) {
        prefsRepository.setChatToken(userInfo['userChatToken']);
      }
      if (userInfo.containsKey('userStoriesToken')) {
        prefsRepository.setStoriesToken(userInfo['userStoriesToken']);
      }
      if (userInfo.containsKey('userChatName')) {
        prefsRepository.setMyChatName(userInfo['userChatName']);
      }
      if (userInfo.containsKey('userStoriesName')) {
        prefsRepository.setMyStoriesName(userInfo['userStoriesName']);
      }
      if (userInfo.containsKey('userChatPhoto')) {
        prefsRepository.setMyChatPhoto(userInfo['userChatPhoto']);
      }
      if (userInfo.containsKey('userProfilePhoto')) {
        prefsRepository.setMyProfilePhoto(userInfo['userProfilePhoto']);
      }
      if (userInfo.containsKey('userStoriesId')) {
        prefsRepository.setMyStoriesId(
            int.tryParse(userInfo['userStoriesId'].toString()) ?? 0);
      }
      if (userInfo.containsKey('userCountryIso')) {
        prefsRepository.setCountryIso(userInfo['userCountryIso']);
      }
      if (userInfo.containsKey('userCountryIsAvailable')) {
        prefsRepository.setUserCountryIsAvailable(
            int.tryParse(userInfo['userCountryIsAvailable'].toString()) ?? 0);
      }
      if (userInfo.containsKey('userUserChoosedCountryIso')) {
        prefsRepository
            .setUserChoosedCountryIso(userInfo['userUserChoosedCountryIso']);
      }
      if (userInfo.containsKey('userVerifiedPhone')) {
        prefsRepository.setVerifiedPhone(
            userInfo['userVerifiedPhone'] == true ||
                userInfo['userVerifiedPhone'] == 'true');
      }
      if (userInfo.containsKey('isVerifiedPhonePeforeExpiredToken')) {
        prefsRepository.setVerifiedPhonePeforeExpiredToken(
            userInfo['isVerifiedPhonePeforeExpiredToken'] == true ||
                userInfo['isVerifiedPhonePeforeExpiredToken'] == 'true');
      }
      if (userInfo.containsKey('isTokenExpired')) {
        prefsRepository.setTokenExpired(userInfo['isTokenExpired'] == true ||
            userInfo['isTokenExpired'] == 'true');
      }
      if (userInfo.containsKey('language')) {
        prefsRepository.setLanguage(userInfo['language']);
      }
      setState(() {
        _error = null;
        _savedUserInfo = userInfo;
      });
      // بعد الحفظ: خزّن الوقت الحالي وuserMarketId فقط
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('last_user_market_id', userInfo['userMarketId'] ?? '');
      prefs.setInt(
          'last_user_info_time', DateTime.now().millisecondsSinceEpoch);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Info saved successfully!')),
      );
      Future.delayed(const Duration(seconds: 1), () {
        GetIt.I<AuthBloc>().add(GetCustomerInfoEvent());
        GetIt.I<HomeBloc>().add(const GetCartItemEvent());
        GetIt.I<HomeBloc>().add(const GetOldCartItemEvent());
        GetIt.I<HomeBloc>().add(GetCurrencyForCountryEvent());
      });
    } catch (e) {
      setState(() {
        _error = 'Invalid JSON format';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Info',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _savedUserInfo == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: 12,
                      minLines: 10,
                      decoration: InputDecoration(
                        hintText: '{ "userMarketId": "...", ... }',
                        border: InputBorder.none,
                        hintStyle: const TextStyle(fontSize: 11),
                        errorText: _error,
                      ),
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "Error Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Table(
                      border:
                          TableBorder.all(color: Colors.deepPurple.shade100),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                      },
                      children: [
                        ..._savedUserInfo!.entries.map((entry) {
                          return TableRow(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                color: Colors.deepPurple.shade50,
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  entry.value is Map || entry.value is List
                                      ? jsonEncode(entry.value)
                                      : entry.value.toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// دالة مساعدة لتحويل النص إلى JSON Map
Map<String, dynamic> userInfoFromJson(String source) {
  return source.isNotEmpty
      ? (source.trim().startsWith('{')
          ? (jsonDecode(source) as Map<String, dynamic>)
          : {})
      : {};
}
