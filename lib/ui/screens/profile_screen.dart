import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mygang/core/router/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: FirebaseAuth.instance.currentUser?.displayName ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null || user == null) {
      return const Scaffold(body: Center(child: Text('Não autenticado.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(user.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nome exibido'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading
                ? null
                : () async {
                    setState(() => _loading = true);
                    try {
                      await users(context).updateProfile(uid: uid, displayName: _name.text);
                      await user.updateDisplayName(_name.text.trim());
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil atualizado.')));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                      }
                    } finally {
                      if (mounted) setState(() => _loading = false);
                    }
                  },
            child: Text(_loading ? 'Salvando…' : 'Salvar nome'),
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () async {
              await users(context).signOut();
              if (mounted) context.go('/login');
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
