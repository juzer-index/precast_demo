import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:aws_common/aws_common.dart';

/// Fetches temporary AWS credentials from a Cognito Identity Pool for unauthenticated users.
class CognitoCredentialsProvider {
  final String identityPoolId;
  final String region; // kept for future use; library infers region from pool id

  CognitoCredentialsProvider({required this.identityPoolId, required this.region});

  Future<AWSCredentials> getCredentials() async {
    // Unauthenticated flow: create a placeholder user pool (not used for unauth)
    final CognitoUserPool userPool = CognitoUserPool('', '');

    // Construct credentials helper with identity pool id
    final credentials = CognitoCredentials(identityPoolId, userPool);

    // Fetch temporary AWS credentials (unauthenticated). Some versions require a positional identityId argument; pass null.
    await credentials.getAwsCredentials(null);

    return AWSCredentials(
      credentials.accessKeyId!,
      credentials.secretAccessKey!,
      credentials.sessionToken,
    );
  }
}
