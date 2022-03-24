import 'package:test/test.dart';

import 'package:bitcoindart/src/ecpair.dart';
import 'package:bitcoindart/src/transaction_builder.dart';
import 'package:bitcoindart/src/models/networks.dart' as networks;
import 'package:bitcoindart/src/payments/p2wpkh.dart' show P2WPKH;
import 'package:bitcoindart/src/payments/index.dart' show PaymentData;

void main() {
  group('bitcoinjs-lib (transactions)', () {
    test('can create a 1-to-1 Transaction', () {
      final alice = ECPair.fromWIF(
          'L1uyy5qTuGrVXrmrsvHWHgVzW9kKdrp27wBC7Vs6nZDTF2BRUVwy');
      final txb = TransactionBuilder();

      txb.setVersion(1);
      txb.addInput(
          '61d520ccb74288c96bc1a2b20ea1c0d5a704776dd0164a396efec3ea7040349d',
          0); // Alice's previous transaction output, has 15000 satoshis
      txb.addOutput('1cMh228HTCiwS8ZsaakH8A8wze1JR5ZsP', 12000);
      // (in)15000 - (out)12000 = (fee)3000, this is the miner fee

      txb.sign(vin: 0, keyPair: alice);

      // prepare for broadcast to the Bitcoin network, see 'can broadcast a Transaction' below
      expect(txb.build().toHex(),
          '01000000019d344070eac3fe6e394a16d06d7704a7d5c0a10eb2a2c16bc98842b7cc20d561000000006b48304502210088828c0bdfcdca68d8ae0caeb6ec62cd3fd5f9b2191848edae33feb533df35d302202e0beadd35e17e7f83a733f5277028a9b453d525553e3f5d2d7a7aa8010a81d60121029f50f51d63b345039a290c94bffd3180c99ed659ff6ea6b1242bca47eb93b59fffffffff01e02e0000000000001976a91406afd46bcdfd22ef94ac122aa11f241244a37ecc88ac00000000');
    });

    test('can create a 2-to-2 Transaction', () {
      final alice = ECPair.fromWIF(
          'L1Knwj9W3qK3qMKdTvmg3VfzUs3ij2LETTFhxza9LfD5dngnoLG1');
      final bob = ECPair.fromWIF(
          'KwcN2pT3wnRAurhy7qMczzbkpY5nXMW2ubh696UBc1bcwctTx26z');

      final txb = TransactionBuilder();
      txb.setVersion(1);
      txb.addInput(
          'b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c',
          6); // Alice's previous transaction output, has 200000 satoshis
      txb.addInput(
          '7d865e959b2466918c9863afca942d0fb89d7c9ac0c99bafc3749504ded97730',
          0); // Bob's previous transaction output, has 300000 satoshis
      txb.addOutput('1CUNEBjYrCn2y1SdiUMohaKUi4wpP326Lb', 180000);
      txb.addOutput('1JtK9CQw1syfWj1WtFMWomrYdV3W2tWBF9', 170000);
      // (in)(200000 + 300000) - (out)(180000 + 170000) = (fee)150000, this is the miner fee

      txb.sign(
          vin: 1,
          keyPair:
              bob); // Bob signs his input, which was the second input (1th)
      txb.sign(
          vin: 0,
          keyPair:
              alice); // Alice signs her input, which was the first input (0th)

      // prepare for broadcast to the Bitcoin network, see 'can broadcast a Transaction' below
      expect(txb.build().toHex(),
          '01000000024c94e48a870b85f41228d33cf25213dfcc8dd796e7211ed6b1f9a014809dbbb5060000006a473044022041450c258ce7cac7da97316bf2ea1ce66d88967c4df94f3e91f4c2a30f5d08cb02203674d516e6bb2b0afd084c3551614bd9cec3c2945231245e891b145f2d6951f0012103e05ce435e462ec503143305feb6c00e06a3ad52fbf939e85c65f3a765bb7baacffffffff3077d9de049574c3af9bc9c09a7c9db80f2d94caaf63988c9166249b955e867d000000006b483045022100aeb5f1332c79c446d3f906e4499b2e678500580a3f90329edf1ba502eec9402e022072c8b863f8c8d6c26f4c691ac9a6610aa4200edc697306648ee844cfbc089d7a012103df7940ee7cddd2f97763f67e1fb13488da3fbdd7f9c68ec5ef0864074745a289ffffffff0220bf0200000000001976a9147dd65592d0ab2fe0d0257d571abf032cd9db93dc88ac10980200000000001976a914c42e7ef92fdb603af844d064faad95db9bcdfd3d88ac00000000');
    });

    test('can create a Transaction, w/ a P2SH(P2WPKH) input', () {
      final alice = ECPair.fromWIF(
          'L2FroWqrUgsPpTMhpXcAFnVDLPTToDbveh3bhDaU4jhe7Cw6YujN');
      final p2wpkh = P2WPKH(data: PaymentData(pubkey: alice.publicKey)).data;
      final redeemScript = p2wpkh.output;

      final txb = TransactionBuilder();
      txb.setVersion(1);
      txb.addInput(
          'ce5986f6d73d7855351fea94c7cf9eb1a4513bf5e004178835d8e2adb9a0f95d',
          0);
      txb.addOutput('1D8nG3VetkT4CfyXGKm7EdLU1YbMD3Amuj', 60000);

      txb.sign(
          vin: 0,
          keyPair: alice,
          redeemScript: redeemScript,
          witnessValue: 80000);
      // prepare for broadcast to the Bitcoin network, see 'can broadcast a Transaction' below
      expect(txb.build().toHex(),
          '010000000001015df9a0b9ade2d835881704e0f53b51a4b19ecfc794ea1f3555783dd7f68659ce0000000017160014851a33a5ef0d4279bd5854949174e2c65b1d4500ffffffff0160ea0000000000001976a914851a33a5ef0d4279bd5854949174e2c65b1d450088ac02483045022100cb3929c128fec5108071b662e5af58e39ac8708882753a421455ca80462956f6022030c0f4738dd1a13fc7a34393002d25c6e8a6399f29c7db4b98f53a9475d94ca20121038de63cf582d058a399a176825c045672d5ff8ea25b64d28d4375dcdb14c02b2b00000000');
    });

    test('can create a Transaction, w/ a P2WPKH input', () {
      final alice = ECPair.fromWIF(
          'cUNfunNKXNNJDvUvsjxz5tznMR6ob1g5K6oa4WGbegoQD3eqf4am',
          network: networks.testnet);
      final p2wpkh = P2WPKH(
              data: PaymentData(pubkey: alice.publicKey),
              network: networks.testnet)
          .data;
      final txb = TransactionBuilder(network: networks.testnet);
      txb.setVersion(1);
      txb.addInput(
          '53676626f5042d42e15313492ab7e708b87559dc0a8c74b7140057af51a2ed5b',
          0,
          null,
          p2wpkh
              .output); // Alice's previous transaction output, has 200000 satoshis
      txb.addOutput('tb1qchsmnkk5c8wsjg8vxecmsntynpmkxme0yvh2yt', 1000000);
      txb.addOutput('tb1qn40fftdp6z2lvzmsz4s0gyks3gq86y2e8svgap', 8995000);

      txb.sign(vin: 0, keyPair: alice, witnessValue: 10000000);
      // // prepare for broadcast to the Bitcoin network, see 'can broadcast a Transaction' below
      expect(txb.build().toHex(),
          '010000000001015beda251af570014b7748c0adc5975b808e7b72a491353e1422d04f5266667530000000000ffffffff0240420f0000000000160014c5e1b9dad4c1dd0920ec3671b84d649877636f2fb8408900000000001600149d5e94ada1d095f60b701560f412d08a007d11590247304402203c4670ff81d352924af311552e0379861268bebb2222eeb0e66b3cdd1d4345b60220585b57982d958208cdd52f4ead4ecb86cfa9ff7740c2f6933e77135f1cc4c58f012102f9f43a191c6031a5ffae27c5f9911218e78857923284ac1154abc2cc008544b200000000');
    });
  });
}
