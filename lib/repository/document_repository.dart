import 'dart:convert';

import 'package:docs_app/constant.dart';
import 'package:docs_app/models/document_model.dart';
import 'package:docs_app/models/error_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final documentRepositoryProvider =
    Provider((ref) => DocumentRepository(client: Client()));

class DocumentRepository {
  final Client _client;

  DocumentRepository({required Client client}) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    ErrorModel error = ErrorModel(error: "Some Unexpected Error", data: null);

    try {
      var res = await _client.post(Uri.parse('$host/doc/create'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token
          },
          body: jsonEncode({
            'createdAt': DateTime.now().microsecondsSinceEpoch,
          }));

      switch (res.statusCode) {
        case 200:
          final document = DocumentModel.fromJson(res.body);
          error = ErrorModel(error: null, data: document);
          break;
        default:
          error = ErrorModel(error: res.body, data: null);
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getDocuments(String token) async {
    ErrorModel error = ErrorModel(error: "Some Unexpected Error", data: null);

    try {
      var res = await _client.get(
        Uri.parse('$host/docs/me'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token
        },
      );

      switch (res.statusCode) {
        case 200:
          List<DocumentModel> documents = [];
          final resp = jsonDecode(res.body);
          for (int i = 0; i < resp.length; i++) {
            documents.add(DocumentModel.fromJson(jsonEncode(resp[i])));
          }

          error = ErrorModel(error: null, data: documents);
          break;
        default:
          error = ErrorModel(error: res.body, data: null);
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  void updateDocumentTitle(
      {required String token,
      required String id,
      required String title}) async {
    await _client.post(
      Uri.parse('$host/doc/title'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token
      },
      body: jsonEncode(
        {'id': id, 'title': title},
      ),
    );
  }

  Future<ErrorModel> getDocument(String token, String documentId) async {
    ErrorModel error = ErrorModel(error: "Some Unexpected Error", data: null);

    try {
      var res = await _client.get(
        Uri.parse('$host/doc/$documentId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token
        },
      );

      switch (res.statusCode) {
        case 200:
          final document = DocumentModel.fromJson(res.body);
          error = ErrorModel(error: null, data: document);
          break;
        default:
          error = ErrorModel(error: res.body, data: null);
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }
}
