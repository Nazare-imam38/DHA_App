// Test script to debug S3 image loading issues
import 'dart:io';
import 'dart:convert';

void main() async {
  await testS3ImageUrls();
}

Future<void> testS3ImageUrls() async {
  print('🧪 Testing S3 Image URL Loading');
  print('=' * 50);
  
  // Sample S3 URLs from your error log
  final testUrls = [
    'https://s3-testing-dha-mp.s3.amazonaws.com/data/690854cb2064a_1762153675.jpg?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAZGTTXLPU3QRSRSIB%2F20251103%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20251103T073654Z&X-Amz-SignedHeaders=host&X-Amz-Expires=720&X-Amz-Signature=b31a0dd5397745218ede8ef2fa8801b69b162220f7d2a46787643ebefc756725',
  ];
  
  for (int i = 0; i < testUrls.length; i++) {
    final url = testUrls[i];
    print('\\n🔍 Testing URL ${i + 1}:');
    print('URL: ${url.substring(0, url.length > 100 ? 100 : url.length)}...');
    
    await testUrlAccess(url);
  }
  
  print('\\n📋 Common S3 CORS Issues & Solutions:');
  print('1. **CORS Configuration**: S3 bucket needs proper CORS policy');
  print('2. **Signed URL Expiry**: URLs expire after X-Amz-Expires seconds');
  print('3. **Region Mismatch**: Ensure correct S3 region in URL');
  print('4. **Permissions**: Check IAM permissions for S3 access');
  print('5. **Content-Type**: Ensure proper image content types');
  
  print('\\n🔧 Recommended S3 CORS Policy:');
  print('''
{
  "CORSRules": [
    {
      "AllowedOrigins": ["*"],
      "AllowedMethods": ["GET", "HEAD"],
      "AllowedHeaders": ["*"],
      "ExposeHeaders": ["ETag"],
      "MaxAgeSeconds": 3000
    }
  ]
}
''');
}

Future<void> testUrlAccess(String url) async {
  try {
    final uri = Uri.parse(url);
    print('   Host: ${uri.host}');
    print('   Path: ${uri.path}');
    
    // Check if it's a signed URL
    if (url.contains('X-Amz-Signature')) {
      print('   ✅ Signed URL detected');
      
      // Check expiry
      final expiresMatch = RegExp(r'X-Amz-Expires=(\d+)').firstMatch(url);
      if (expiresMatch != null) {
        final expires = int.tryParse(expiresMatch.group(1) ?? '0') ?? 0;
        print('   ⏰ Expires in: ${expires}s (${expires / 60} minutes)');
      }
      
      // Check date
      final dateMatch = RegExp(r'X-Amz-Date=(\w+)').firstMatch(url);
      if (dateMatch != null) {
        final dateStr = dateMatch.group(1) ?? '';
        print('   📅 Signed date: $dateStr');
      }
    }
    
    // Try to make HTTP request
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    
    final request = await client.getUrl(uri);
    request.headers.add('Accept', 'image/*');
    request.headers.add('User-Agent', 'DHA-Marketplace-App/1.0');
    
    final response = await request.close();
    print('   📡 HTTP Status: ${response.statusCode}');
    print('   📄 Content-Type: ${response.headers.contentType}');
    print('   📏 Content-Length: ${response.headers.contentLength ?? 'Unknown'}');
    
    if (response.statusCode == 200) {
      print('   ✅ URL accessible');
    } else {
      print('   ❌ URL not accessible');
    }
    
    client.close();
    
  } catch (e) {
    print('   ❌ Error accessing URL: $e');
    
    if (e.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
      print('   💡 SSL Certificate issue - may need certificate validation');
    } else if (e.toString().contains('Connection refused')) {
      print('   💡 Connection refused - check network/firewall');
    } else if (e.toString().contains('No address associated')) {
      print('   💡 DNS resolution failed - check domain');
    }
  }
}