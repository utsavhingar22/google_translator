// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/language_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String sourceLanguage = 'en';
  String targetLanguage = 'es';
  String translatedText = '';
  TextEditingController textController = TextEditingController();
  final ApiService apiService = ApiService();
  bool isLoading = false;

  void selectLanguage(String type) async {
    try {
      final languages = await apiService.fetchLanguages();
      if (kDebugMode) {
        print('Languages data: $languages');
      }

      // Safely process languages
      final validLanguages = languages
          .where((lang) => lang['language'] != null)
          .map((lang) => {'language': lang['language'].toString()})
          .toList();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) {
          TextEditingController searchController = TextEditingController();
          List<Map<String, String>> filteredLanguages = validLanguages;

          void filterLanguages(String query) {
            setState(() {
              filteredLanguages = validLanguages
                  .where((lang) =>
                  lang['language']!.toUpperCase().contains(query.toUpperCase()))
                  .toList();
            });
          }

          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 16.0,
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: filterLanguages,
                    decoration: const InputDecoration(
                      labelText: 'Search Language',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: filteredLanguages.map((lang) {
                        return ListTile(
                          title: Text(
                            lang['language']!.toUpperCase(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            setState(() {
                              if (type == 'source') {
                                sourceLanguage = lang['language']!;
                              } else {
                                targetLanguage = lang['language']!;
                              }
                            });
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          });
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error selecting language: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load languages: $e')),
      );
    }
  }

  void translateText() async {
    setState(() {
      isLoading = true;
    });
    try {
      final translation = await apiService.translate(
        textController.text,
        sourceLanguage,
        targetLanguage,
      );
      setState(() {
        translatedText = translation;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Translation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LanguageSelector(
                  language: sourceLanguage,
                  onTap: () => selectLanguage('source'),
                ),
                const Icon(Icons.swap_horiz, color: Colors.white),
                LanguageSelector(
                  language: targetLanguage,
                  onTap: () => selectLanguage('target'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'Enter text',
                hintStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.grey, // Background color for the input field
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0), // Padding inside the field
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: translateText,
              child: const Text('Translate'),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : TextField(
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Translated text',
                hintStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.grey, // Background color for the input field
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0), // Padding inside the field
              ),
              controller: TextEditingController(text: translatedText),
            ),
          ],
        ),
      ),
    );
  }
}
