import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/services.dart' show rootBundle;

class FilePickerWidget extends StatefulWidget {
  @override
  _FilePickerWidgetState createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  String? _fileName;
  String? _fileType;
  FilePickerResult? _fileResult;
  String? _resultFilePath;
  
  Future<void> uploadToDrive(String filePath) async {
      var credentials = auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "confident-coder-324807",
        "private_key_id": "92c0169892508f1afb1a60fb9d4f3b963c139f56",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCw8i4OLZgTS6Vb\nGsn1eLMcjyS0cu5aMg8KOcySPXcY9gxZcz6PGikfBNwGkr+FSyAziDrdcr0g6azk\nTBnvfg/Yd7oJE7YLMFPpLlm9yFjtiKo+5s7Vbo211VBd/Frx8nAj5Wp4dT2zZ0Zd\n/dY5tSV7mfWCg9GEw2oHkTeJliSR1ATNfnmej0aCS4iwdqB2Jf9kkc80PY0bAIgl\nR55XFt1fX2WbM7JMx0OeHYg8tyG1hi3USdcoYPIMB8RP37njZvVvs1Ch3reINp5+\n/MJ/P49QQ0RPF10MBKKsUcw0ATlUoBQv7DfgWaPnuTV8zy3nDSfSstdG4JiRWVD3\nOTBS1uR5AgMBAAECggEAJuegs7JXqQptWXoq5IN80i8w8VIB0SgHgYaS0aadDIpw\nzawWma01VGIjpHhYjsylUF9IHg+PwPBP+MQ4wZ0Ui9JLP5qrYItoL7FmvuERmGx/\njiP+XxQXKV808+07682T1XioL8MLZWo0IQ9iLj8Ddkk0H1WvWAMFSZOmw+QUt1Ep\nuOD0Yejdd/KxmOSXHVyFsLH+9qVzNyg6WkGbMoTxXjIphqR3tkS/Rk7hfzlQj94C\njexyzrlXQn4GXcBdbkxkAGvbaGD3WiqUuehjVtBqNATm2dXPoSvU9+2KEU9CdECY\n/7W6SFzirjI6eMKiVBoR7FL4p5ZYRyNC/sHwTfOujwKBgQDyYLqpEwpObMu4qSMH\nm4Ip92awZal/3DBwBELEE+diYvNO9ktTTqGo4wTJwPip5s5XITx/jfaU9IvBE9Ic\nYzY5O4Cq9bIFQG3vCeyqF73vheyjT+xqcY3VPzgU7+PYiJova31Yn/5gTVINVOdx\nQ2ZFC2XUnqhHEh8Ny9dQ2tM+HwKBgQC65AjATOPAzucoLqhC1y6ae9J3A0z2nAhJ\nwjzeqovAHH1KeuiqstifkjSPb97poaKuQZSL8qObLZ2p/+k1l9KIwbmJ+t8gLcsa\nfTTiaycbFoa5Uro/0uhTN71uIDr7Bh363OJQ6HuLUsEKjs3pjnn/3QoakbXdVXxL\n5Gq+975aZwKBgQDpNLrEzQYgmTuWrF6BBlZCLMHIPbjNxj1wuhjHcmMyXgS+1+l3\n+XM//VZxDNP1HZcxbFA6Zox3m6gQGRMTrz3P6XmOhKJJvUlJMuJcckWU/eXG6LKP\nZDzUjmRWeM5gXGcF80WCjUaCwEKPgz7A0tnG2wWagyFkaIIqkxPTvwh7fwKBgQCX\nOYmzQQRRsZnuM8LHQyNcsbDdyHfwXNWACYIDkvC+JM9lAwtdhJYwmLebESTI25et\ndTdj/pRQLpsTQhZM3WroagleEveVLDjaWFIAnD/qdVHSh5RZrKl9HO9VOxM+p/Z+\nVVlzqoq9c9rsVh1cTYN+fDd+xETqsg9/wXZ2zDTlJQKBgDLyvlIjXgi+KCaGc14C\nxFtcgqj4Gv87jpJx4Zq8fpS+bq5JNHleaNR9gR1C+4hiyMLT2/IGKtVTINZ40YiD\nCixIKEfdyUOHBg+DroENhgR9TW4qizEHEeG/WanJ7e7hmftMijWHPebAKX+zsbl6\nH5o+45ubkOxaXZqG+60zBQo1\n-----END PRIVATE KEY-----\n",
        "client_email": "people360-consulting-corporati@confident-coder-324807.iam.gserviceaccount.com",
        "client_id": "101477446058176692364",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/people360-consulting-corporati%40confident-coder-324807.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      }),
      ['https://www.googleapis.com/auth/drive.file'],
    );
    var authClient = await credentials;
    var driveApi = drive.DriveApi(authClient);

    var driveFile = drive.File();
    driveFile.name = filePath.split('/').last;

    var file = File(filePath);
    var media = drive.Media(file.openRead(), file.lengthSync());

    var result = await driveApi.files.create(
      driveFile,
      uploadMedia: media,
    );

    if (result != null) {
      print('File uploaded successfully');
      print('File ID: ${result.id}');
    } else {
      print('Error uploading file');
    }

    
    authClient.close();
  }
  void _openFilePicker() async {
    _fileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Specify the file types you want to allow
      allowedExtensions: ['pdf', 'doc', 'xls'],
    );

    if (_fileResult != null) {
      setState(() {
        _resultFilePath = _fileResult?.files.single.path;
        _fileName = _fileResult?.files.first.name;
        _fileType = _fileResult?.files.first.extension;
      });
    }
  }
  void runFile(){
    uploadToDrive(_resultFilePath!);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _openFilePicker,
          child: Text('Pick File'),
        ),
        SizedBox(height: 10),
        Text('Selected File: $_fileName'),
        Text('File Type: $_fileType'),
        ElevatedButton(onPressed: runFile, child: const Text('Test'))
      ],
    );
  }
}