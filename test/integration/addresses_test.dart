import 'package:bitcoindart/src/models/networks.dart' as networks;
import 'package:bitcoindart/src/ecpair.dart' show ECPair;
import 'package:bitcoindart/src/payments/index.dart' show PaymentData;
import 'package:bitcoindart/src/payments/p2sh.dart' show P2SH;
import 'package:bitcoindart/src/payments/p2pkh.dart' show P2PKH;
import 'package:bitcoindart/src/payments/p2wpkh.dart' show P2WPKH;
import 'package:pointycastle/digests/sha256.dart';
import 'dart:convert';
import 'package:test/test.dart';

networks.NetworkType litecoin = networks.NetworkType(
    messagePrefix: '\x19Litecoin Signed Message:\n',
    bip32: networks.Bip32Type(public: 0x019da462, private: 0x019d9cfe),
    pubKeyHash: 0x30,
    scriptHash: 0x32,
    wif: 0xb0);
// deterministic RNG for testing only
List<int> rng(int number) {
  return utf8.encode('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz');
}

void main() {
  group('bitcoinjs-lib (addresses)', () {
    test('can generate a random address', () {
      final keyPair = ECPair.makeRandom(rng: rng);
      final address =
          P2PKH(data: PaymentData(pubkey: keyPair.publicKey)).data.address;
      expect(address, '1F5VhMHukdnUES9kfXqzPzMeF1GPHKiF64');
    });
    test('can generate an address from a SHA256 hash', () {
      final hash =
          SHA256Digest().process(utf8.encode('correct horse battery staple'));
      final keyPair = ECPair.fromPrivateKey(hash);
      final address =
          P2PKH(data: PaymentData(pubkey: keyPair.publicKey)).data.address;
      expect(address, '1C7zdTfnkzmr13HfA2vNm5SJYRK6nEKyq8');
    });
    test('can import an address via WIF', () {
      final keyPair = ECPair.fromWIF(
          'Kxr9tQED9H44gCmp6HAdmemAzU3n84H3dGkuWTKvE23JgHMW8gct');
      final address =
          P2PKH(data: PaymentData(pubkey: keyPair.publicKey)).data.address;
      expect(address, '19AAjaTUbRjQCMuVczepkoPswiZRhjtg31');
    });
    test('can generate a Testnet address', () {
      final testnet = networks.testnet;
      final keyPair = ECPair.makeRandom(network: testnet, rng: rng);
      final wif = keyPair.toWIF();
      final address =
          P2PKH(data: PaymentData(pubkey: keyPair.publicKey), network: testnet)
              .data
              .address;
      expect(address, 'mubSzQNtZfDj1YdNP6pNDuZy6zs6GDn61L');
      expect(wif, 'cRgnQe9MUu1JznntrLaoQpB476M8PURvXVQB5R2eqms5tXnzNsrr');
    });
    test('can generate a Litecoin address', () {
      final keyPair = ECPair.makeRandom(network: litecoin, rng: rng);
      final wif = keyPair.toWIF();
      final address =
          P2PKH(data: PaymentData(pubkey: keyPair.publicKey), network: litecoin)
              .data
              .address;
      expect(address, 'LZJSxZbjqJ2XVEquqfqHg1RQTDdfST5PTn');
      expect(wif, 'T7A4PUSgTDHecBxW1ZiYFrDNRih2o7M8Gf9xpoCgudPF9gDiNvuS');
    });
    test('can generate a SegWit address', () {
      final keyPair = ECPair.fromWIF(
          'KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn');
      final address =
          P2WPKH(data: PaymentData(pubkey: keyPair.publicKey)).data.address;
      expect(address, 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4');
    });
    test('can generate a SegWit Testnets address', () {
      final testnet = networks.testnet;
      final keyPair = ECPair.fromWIF(
          'cPaJYBMDLjQp5gSUHnBfhX4Rgj95ekBS6oBttwQLw3qfsKKcDfuB');
      final address =
          P2WPKH(data: PaymentData(pubkey: keyPair.publicKey), network: testnet)
              .data
              .address;
      expect(address, 'tb1qgmp0h7lvexdxx9y05pmdukx09xcteu9sx2h4ya');
    });

    test('can generate a SegWit address (via P2SH)', () {
      final keyPair = ECPair.fromWIF(
          'KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn');
      final address = P2SH(
              data: PaymentData(
                  redeem: P2WPKH(data: PaymentData(pubkey: keyPair.publicKey))
                      .data))
          .data
          .address;
      expect(address, '3JvL6Ymt8MVWiCNHC7oWU6nLeHNJKLZGLN');
    });
  });
}