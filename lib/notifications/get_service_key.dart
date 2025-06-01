import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  static Future<String> getServerKey() async {
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "mad-hms",
        "private_key_id": "5fd417c7bde29ecb64976c420a5573e3dd72ba43",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCOBUR/xjYh99yN\ngEwMpTKMLgMi0oB9w3ChOfuMCZ3TO/htlWZCWNvBBnRSC/gAWx8FL3TH7xr3+XIo\n9MOEpZGqsdzM9NHDcl5MdxzLsO0VQw1+7h/AeB6vLzv4qM35emaorI2mBSP4JCiv\nRIEewH6NMN0NiLW2QE4WjXXsvv90elIYCwgxVmE3vFYnAaJpWVN49zXbziwHRXa/\n8MI8BYe7OlwNN3JeaZP4hgXVC4nMA3OO4yXB+yLNUONJo3Kz5n5xcZw5e5v2/Yyl\nR1kGxRrv4YTBiFA6PdVqf0Fv9y40fAGxw01aai4uXG9YW2Uwizbwxoil2SBxQsIe\n8SS6NNx9AgMBAAECggEAPBNRWwVy/6J0Cu1C/jRhMfgCvpex38EtIx4+YInu15xu\nJZjFhXpGFxxOVyiV8zyYXh6pdSuZSl0b4+RJ0pIhEMYlIxPKqbT227ylEyrX1x8i\nlddP2iBVxoAiC7kITChxRZecYaaaBQzyotVFE0eVIM+TKnbyetIv1g1n3UocEF5O\ni4P6rL0dq7HRtTCPzAIX2fOODqmGCG/6+xR4DGD+AjtPvKDS15hHQfnUbt95/E+3\nvH2g1egGd2by4hEUmvp+pUo7ArXifH7AGY0688JKlArVx/v4VvtGw3q35vNbd46s\n7jgEzAhkmM8HNydDM3lBCPGiOlj8s3QY934SOH9bpwKBgQC/WQEHPGfn9kVAwTF1\nUJ6xsmMWP7Q22csybTsMQVl4nn+okuixtfFiwNLUVWst/ZZAOFjYdbp7CUsFLw/+\nPNr5PoiNIq1w2uJt44r3BySDHppFJ3MOrOlZQK+BYrGVTjj4hBoKufSJKnJai8Rr\nx4B29drjclIseGl37UXWOKhxxwKBgQC+AZ5joPE0CC82nRn9w+FGRGllXBCbKnnv\naZV1Z5PNJiU5enWdn6Ua4cOZXD25EiZMbjfrR30o/zKVGe8+OMR3GsXazygjGZ6k\n/VAh/sQqVOa7fMHHZ6Etye+PIZSaTJwYzvtI0pT9TtO9CxCru7HXXUiUGEK7zfT8\nBQLpRgg/mwKBgBrYtv8353AxKlhCgtjt3cYavDJD79n+RrclgjJe/Nmii1Cwg/tj\nBqIPYcUu0uHaAXmzLiv4oJhgnmj0yG6oRSTRNEFxCxqZa0l1smqkUugepBBtz4PQ\nmNDP9Y/WtAm5tt6PUkQNARU5ol+32nAwxoJqTjK5OHRK1Klh3fmHa4LDAoGAFaML\njV7beMhhz/9N4Wb39U9/DQrR3UmV/xxv56G25Aqu/H+keyGd5JTG+GTXpoaZk+SN\nO561cwC0muQMKXK/dKy40TT75htZxIIQKP7hCc0HRVxsmK+FXDh9rjftuzB0KiMP\n3HgWfU4HsKRc7qF+G/9Eb5DfsJFAj55meXf/IncCgYBMBjeV2U77cLUZtjzeJ7yk\nVQta8ZRGIqtLW/OgvkXZO1A14Fwu1FdzZrVVHMX3KRZ16GXgFTHkWMHmVTdh7zS1\nE+BYEXc1+y4N198pKDD9HmzrBnhsEihYEdclLWNdJgsvFhejil6yG+VIhB8ZDS8d\nslMM7O1JkP9LHnUE8cU5Pw==\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-fbsvc@mad-hms.iam.gserviceaccount.com",
        "client_id": "117494436255957687157",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40mad-hms.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com",
      }),
      scopes,
    );

    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
