import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/key_investors/view/widgets/investor_card.dart';
import 'package:investify/features/key_investors/view/widgets/no_investor_state.dart';
import 'package:investify/services/firestore_service.dart';
import 'package:investify/utils/sizes/size.dart';

class KeyInvestorsScreen extends StatefulWidget {
  const KeyInvestorsScreen({super.key});

  @override
  State<KeyInvestorsScreen> createState() => _KeyInvestorsScreenState();
}

class _KeyInvestorsScreenState extends State<KeyInvestorsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _investors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvestors();
  }

  Future<void> _loadInvestors() async {
    setState(() => _isLoading = true);
    try {
      final investors = await _firestoreService.getKeyInvestors();
      setState(() {
        _investors = investors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load investors');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Key Investors Contact'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: MySizes.xxxl),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : _investors.isEmpty
          ? NoInvestorState()
          : RefreshIndicator(
              onRefresh: _loadInvestors,
              child: ListView.builder(
                padding: const EdgeInsets.all(MySizes.containerPadding),
                itemCount: _investors.length,
                itemBuilder: (context, index) {
                  final investor = _investors[index];
                  return InvestorCard(investor: investor);
                },
              ),
            ),
    );
  }
}
