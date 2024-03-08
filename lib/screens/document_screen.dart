import 'dart:async';

import 'package:docs_app/colors.dart';
import 'package:docs_app/common/widgets/loader.dart';
import 'package:docs_app/constant.dart';
import 'package:docs_app/models/document_model.dart';
import 'package:docs_app/models/error_model.dart';
import 'package:docs_app/repository/auth_repository.dart';
import 'package:docs_app/repository/document_repository.dart';
import 'package:docs_app/repository/socket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController =
      TextEditingController(text: 'Untitled Document');
  quill.QuillController? _controller;
  ErrorModel? errorModel;
  ScoketRepository socket = ScoketRepository();

  @override
  void initState() {
    super.initState();
    socket.joinRoom(widget.id);
    fetchDocumentData();

    socket.changeListener((data) {
      _controller?.compose(
          Delta.fromJson(data['delta']),
          _controller?.selection ?? const TextSelection.collapsed(offset: 0),
          quill.ChangeSource.remote);
    });

    Timer.periodic(const Duration(seconds: 3), (timer) {
      socket.autoSave(<String, dynamic>{
        'delta': _controller!.document.toDelta(),
        'room': widget.id,
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  void fetchDocumentData() async {
    
    errorModel = await ref
        .read(documentRepositoryProvider)
        .getDocument(ref.read(userProvider)!.token, widget.id);
    if (errorModel!.data != null) {
      titleController.text = (errorModel!.data as DocumentModel).title;
      _controller = quill.QuillController(
        document: errorModel!.data.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                Delta.fromJson(errorModel!.data.content)),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } 
    setState(() {});

    _controller!.document.changes.listen((event) {
      // 1 -> entire content of document (event.before<Delta>)
      // 2 -> changes that are made from the previous part (event.change<Delta>)
      // 3 -> local? -> we have typed (event.source<ChangeSource>)

      if (event.source == quill.ChangeSource.local) {
        Map<String, dynamic> map = {
          'delta': event.change,
          'room': widget.id,
        };

        socket.typing(map);
      }
    });
  }

  void updateDocumentTitle(WidgetRef ref, String title) {
    ref.read(documentRepositoryProvider).updateDocumentTitle(
        token: ref.read(userProvider)!.token, id: widget.id, title: title);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        body: Loader(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10, right: 5),
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(
                        ClipboardData(text: '$host/#/document/${widget.id}'))
                    .then(
                  (value) => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link Cpoied'),
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.lock,
                color: kWhiteColor,
                size: 14,
              ),
              label: const Text(
                'Share',
                style: TextStyle(color: kWhiteColor),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: kBlueColor),
            ),
          ),
        ],
        backgroundColor: kWhiteColor,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Routemaster.of(context).replace('path');
                },
                child: Image.asset(
                  'assets/images/docs-logo.png',
                  height: 40,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: TextField(
                  onSubmitted: (val) => updateDocumentTitle(ref, val),
                  controller: titleController,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: kBlueColor,
                        ),
                      ),
                      contentPadding: EdgeInsets.only(left: 10)),
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: kGreyColor,
                width: 0.1,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          quill.QuillToolbar.simple(
              configurations: quill.QuillSimpleToolbarConfigurations(
                  controller: _controller!)),
          Expanded(
              child: SizedBox(
            width: 750,
            child: Card(
              color: kWhiteColor,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: quill.QuillEditor.basic(
                    configurations: quill.QuillEditorConfigurations(
                        controller: _controller!, readOnly: false)),
              ),
            ),
          ))
        ],
      ),
    );
  }
}
