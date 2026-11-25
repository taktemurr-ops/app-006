import 'package:flutter_test/flutter_test.dart';
import 'package:uyg_makro_besin_hesaplayici/uyg_makro_besin_hesaplayici.dart';

void main() {
  test('33 dilde ad ve açıklama, doğru kimlik', () {
    expect(makroBesinHesaplayiciTool.id, makroBesinHesaplayiciId);
    expect(makroBesinHesaplayiciTool.title.length, 33);
    expect(makroBesinHesaplayiciTool.tagline.length, 33);
  });
}
