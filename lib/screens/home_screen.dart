import 'package:docs_app/colors.dart';
import 'package:docs_app/common/widgets/loader.dart';
import 'package:docs_app/models/document_model.dart';
import 'package:docs_app/repository/auth_repository.dart';
import 'package:docs_app/repository/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signout(WidgetRef ref) {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDoc(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackBar = ScaffoldMessenger.of(context);

    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);
    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackBar.showSnackBar(SnackBar(content: Text(errorModel.error!)));
    }
  }

  void navigateToDocument(BuildContext context, String documentId) {
    Routemaster.of(context).push('/document/$documentId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController docIdController = TextEditingController();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kWhiteColor,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                createDoc(context, ref);
              },
              icon: const Icon(
                Icons.add,
                color: kBlackColor,
              ),
            ),
            IconButton(
              onPressed: () {
                signout(ref);
              },
              icon: const Icon(
                Icons.logout,
                color: kBlackColor,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              child: TextField(
                onSubmitted: (val) =>
                    navigateToDocument(context, docIdController.text),
                controller: docIdController,
                decoration: InputDecoration(
                    hintText: 'Enter DocumentId',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                    ),
                    border: InputBorder.none,
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: kBlueColor,
                      ),
                    ),
                    contentPadding: const EdgeInsets.only(left: 10)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: kGreyColor,
                  width: 0.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Select Documents from Below',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: FutureBuilder(
                  future: ref
                      .watch(documentRepositoryProvider)
                      .getDocuments(ref.watch(userProvider)!.token),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loader();
                    } else {
                      return Center(
                        child: (snapshot.data!.data.length != 0)
                            ? SizedBox(
                                width: 600,
                                child: ListView.builder(
                                  itemCount: snapshot.data!.data.length,
                                  itemBuilder: (BuildContext context, int i) {
                                    DocumentModel document =
                                        snapshot.data!.data[i];
                                    return InkWell(
                                      onTap: () => navigateToDocument(
                                          context, document.id),
                                      child: SizedBox(
                                        height: 50,
                                        child: Card(
                                          child: Center(
                                            child: Text(
                                              document.title,
                                              style:
                                                  const TextStyle(fontSize: 17),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Text('NO DOCUMENTS AVALIABLE'),
                      );
                    }
                  }),
            ),
          ],
        ));
  }
}
