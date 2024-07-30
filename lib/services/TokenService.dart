//Generate a JWT token
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class JWTService {
  String generateTokenId(String userId, String userEmail, String secret) {
    final expiration = DateTime.now()
            .add(const Duration(minutes: 30))
            .millisecondsSinceEpoch ~/
        1000;
    final payload = {
      'userId': userId,
      'userEmail': userEmail,
      'exp': expiration
    };

    final jwt = JWT(payload);
    final token = jwt.sign(SecretKey(secret));
    return token;
  }

// Function to verify a JWT token
  Map<String, dynamic> verifyToken(String token, String secret) {
    try {
      final decodedJWT = JWT.verify(token, SecretKey(secret));
      return decodedJWT.payload;
    } catch (e) {
      throw Exception('Token verification failed: $e');
    }
  }

  bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      print("Error in isTOkenExpired function: $e");
      return true;
    }
  }
}
