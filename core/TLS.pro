 ////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// TLSKeys
////////////////////////////////////////////////////////////////////////////////////////////////////

// Holds keys for RSA+AES+MAC.
class TLSKeys
{
    u8[] clientKey;    // client to server
    u8[] clientKeyMAC; // client to server MAC
    u8[] serverKey;    // server to client
    u8[] serverKeyMAC; // server to client MAC
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// TLS
////////////////////////////////////////////////////////////////////////////////////////////////////

// Transport Layer Security. Part of HTTPS. Support for TLS 1.2. Pronto's TLS support (PTLS) is a
// modern and intentionally a very narrow implemenation of TLS 1.2. Many of the most serious TLS
// vulnerabilites are related to older ciphers suites (3DES, RC4 etc.), weak export ciphers and
// support for prior TLS versions (downgrade to 1.1, 1.0 or SSL 3.0). Pronto's TLS support is 1.2+
// only with no support for older cipher suites (AES 128/256 only), no weak export ciphers support,
// no TLS alerts/errors (to help mitigate timing attacks), no downgrade versions of TLS/SSL, no
// renegotiation supports (server or client) etc.
//
// The only mandatory cipher mode for TLS 1.2 is TLS_RSA_WITH_AES_128_CBC_SHA which is effectively
// the worst security protection Pronto's TLS 1.2 implemenation supports.
//
// Implementation is based on RFC 5246 https://tools.ietf.org/html/rfc5246 (RFC 5246). Pronto's 
// TLS support (PTLS) library has not been externally audited. 
// 
// We have a list here of known vulnerabilities we have tried to address via fixes or mitigations.
//
// KNOWN VULNERABITLIES and fixes/mitigations we have implemented.
//
// 3SHAKE / TLS Renego MITM
// - Description: Man-in-the-middle attack that uses TLS renegotiate to connect to a server on the 
// client's behalf.
// - Fix/Mitigation: PTLS does not support renegotation by the client or server.
//
// POODLE (CVE-2014-8730)
// - Description: POODLE (Padding Oracle On Downgraded Legacy Encryption) is a 
// man-in-the-middle attack that relies on a protocol downgrade from TLS 1.0, 1.1 or 1.2 to SSLv3.0
// to attempt a brute-force attack against CBC padding.
// - Fix/Mitigation: PTLS does not support downgrades from TLS 1.2 at all. PTLS does not provide TLS
// alerts for padding errors (or errors in general) to help mitigate timing attacks. PTLS handles
// errors with a fixed-timing disconnect where the timing is independent of message/error processing.
//
// LOGJAM/FREAK
// - Description: Exploits that rely on weak "export ciphers".
// - Fix/Mitigation: PTLS does not support any weak export ciphers.
//
// Bleichenbacher Attack (which has many derivatives).
// - Description: Attacks against padding in RSA-PKCS#1 v1.5.
// - Fix/Mitigation: PTLS does not send alerts for bad MAC (message authentication codes) or the like.
// PTLS does not immeaditely close connections that are invalidated either due to MAC errors and the 
// like (letting them timeout etc.). This alone is not sufficient to fully prevent timing attacks but
// helps make them less practical. PTLS handles errors with a fixed-timing disconnect where the timing 
// is independent of message/error processing.
// 
// LUCKY13 (CVE-2013-0169)
// - Description: The TLS protocol 1.1 and 1.2 do not properly consider timing side-channel attacks on
// a MAC check requirement during the processing of malformed CBC padding, which allows remote attackers
// to conduct distinguishing attacks and plaintext-recovery attacks via statistical analysis of timing
// data for crafted packets, aka the "Lucky Thirteen" issue.
// - Fix/Mitigation: PTLS does not send alerts for bad MAC (message authentication codes) or the like.
// This alone is not sufficient to fully prevent timing attacks but helps make them less practical. PTLS
// handles errors with a fixed-timing disconnect where the timing is independent of message/error 
// processing.
//
// In general Pronto is resistant to timing attacks because before each message is processed Pronto 
// commits to disconnecting the connection at a fixed point in the future, independent of time taken
// to process the message contents. If there is a bad handshake/MAC the result is the same for all
// cases: disconnect at a future time before the message was processed with no errors/responses from
// PTLS.
// 
class TLS
{
    const u32 CIPHER_NULL = 0x0000; // unusable, error mode

    // Classic RSA (no forward secrecy) - TLS 1.2 or older only
    const u32 CIPHER_RSA_AES128_CBC_SHA          = 0x002F;
    const u32 CIPHER_RSA_AES256_CBC_SHA          = 0x0035;
    const u32 CIPHER_RSA_AES128_CBC_SHA256       = 0x003C;
    const u32 CIPHER_RSA_AES256_CBC_SHA256       = 0x003D;
    const u32 CIPHER_RSA_AES128_GCM_SHA256       = 0x009C;
    const u32 CIPHER_RSA_AES256_GCM_SHA384       = 0x009D;

    // Ephemeral Diffie-Hellman (forward secrecy) - TLS 1.2/1.3
    const u32 CIPHER_DHE_RSA_AES128_CBC_SHA      = 0x0033;
    const u32 CIPHER_DHE_RSA_AES256_CBC_SHA      = 0x0039;
    const u32 CIPHER_DHE_RSA_AES128_CBC_SHA256   = 0x0067;
    const u32 CIPHER_DHE_RSA_AES256_CBC_SHA256   = 0x006B;
    const u32 CIPHER_DHE_RSA_AES128_GCM_SHA256   = 0x009E;
    const u32 CIPHER_DHE_RSA_AES256_GCM_SHA384   = 0x009F;

    // Elliptic Curve Diffie-Hellman (forward secrecy) - TLS 1.2/1.3
    const u32 CIPHER_ECDHE_RSA_AES128_CBC_SHA    = 0xC013;
    const u32 CIPHER_ECDHE_RSA_AES256_CBC_SHA    = 0xC014;
    const u32 CIPHER_ECDHE_RSA_AES128_CBC_SHA256 = 0xC027;
    const u32 CIPHER_ECDHE_RSA_AES128_GCM_SHA256 = 0xC02F;
    const u32 CIPHER_ECDHE_RSA_AES256_GCM_SHA384 = 0xC030;

    // Note we don't support Digital Signature Algorithm (ECDSA variants)
    // because it hasn't seen significant adoption for TLS (vs RSA).

    const u8 UNSUPPORTED_ALGORITHM   = 0x00;
    const u8 RSA_SIGN_RSA            = 0x01;
    const u8 RSA_SIGN_MD5            = 0x04;
    const u8 RSA_SIGN_SHA1           = 0x05;
    const u8 RSA_SIGN_SHA256         = 0x0B;
    const u8 RSA_SIGN_SHA384         = 0x0C;
    const u8 RSA_SIGN_SHA512         = 0x0D;

    // Elliptic Curves
    const u8 EC_PUBLIC_KEY           = 0x11;
    const u8 EC_prime192v1           = 0x12;
    const u8 EC_prime192v2           = 0x13;
    const u8 EC_prime192v3           = 0x14;
    const u8 EC_prime239v1           = 0x15;
    const u8 EC_prime239v2           = 0x16;
    const u8 EC_prime239v3           = 0x17;
    const u8 EC_prime256v1           = 0x18;
    const u8 EC_secp224r1            = 21;
    const u8 EC_secp256r1            = 23;
    const u8 EC_secp384r1            = 24;
    const u8 EC_secp521r1            = 25;

    // TLS Alert codes
    const u8 ALERT_CLOSE_NOTIFY             = 0;
    const u8 ALERT_UNEXPECTED_MSG           = 10;
    const u8 ALERT_BAD_RECORD_MAC           = 20;
    const u8 ALERT_DECRYPT_FAIL_RESERVED    = 21;
    const u8 ALERT_RECORD_OVERFLOW          = 22;
    const u8 ALERT_DECOMPRESS_FAIL          = 30;
    const u8 ALERT_HANDSHAKE_FAIL           = 40;
    const u8 ALERT_NO_CERT_RESERVED         = 41;
    const u8 ALERT_BAD_CERT                 = 42;
    const u8 ALERT_UNSUPPORTED_CERT         = 43;
    const u8 ALERT_CERT_REVOKED             = 44;
    const u8 ALERT_CERT_EXPIRED             = 45;
    const u8 ALERT_CERT_UNKNOWN             = 46;
    const u8 ALERT_ILLEGAL_PARAM            = 47;
    const u8 ALERT_UNKNOWN_CERT_AUTHORITY   = 48;
    const u8 ALERT_ACCESS_DENIED            = 49;
    const u8 ALERT_DECODE_ERROR             = 50;
    const u8 ALERT_DECRYPT_ERROR            = 51;
    const u8 ALERT_EXPORT_RESTRICT_RESERVED = 60;
    const u8 ALERT_PROTOCOL_VERSION         = 70;
    const u8 ALERT_GARBAGE_SECURITY         = 71;
    const u8 ALERT_INTERNAL_ERROR           = 80;
    const u8 ALERT_BAD_FALLBACK             = 86;
    const u8 ALERT_USER_HAD_LEFT_THE_CHAT   = 90;
    const u8 ALERT_NO_RENEGOTIATION         = 100;
    const u8 ALERT_UNKNOWN_EXTENSION        = 110;
    const u8 ALERT_NO_ERROR                 = 255;

    // TLS Severity, basically warnings and fatal errors
    const u8 ALERT_LEVEL_WARNING = 1;
    const u8 ALERT_LEVEL_ERROR   = 2;

    // Minor Version numbers in packet, major is always 0x03
    const u8 VER_NULL = 0x00; // technically SSL 3.0 is "0" which is useless, so we use as error code
    const u8 VER_1_0  = 0x01; // we don't support 
    const u8 VER_1_1  = 0x02; // we don't support 
    const u8 VER_1_2  = 0x03; // supported, minimum
    const u8 VER_1_3  = 0x04; // TBD WIP support

    // Record types (byte)
    const u8 RECORD_TYPE_NULL          = 0x00;
    const u8 RECORD_TYPE_CHANGE_CIPHER = 0x14;
    const u8 RECORD_TYPE_ALERT         = 0x15;
    const u8 RECORD_TYPE_HANDSHAKE     = 0x16; // this is 10 message types, see handshake sub-record types
    const u8 RECORD_TYPE_APP_DATA      = 0x17;

    // Handshake sub-record types
    const u8 HANDSHAKE_SERVER_RESTART             = 0x00; // Allows renegotiation by server. Do not support.
    const u8 HANDSHAKE_CLIENT_HELLO               = 0x01; // Begins a TLS handshake negotiation. List of client supported cipher suites.
    const u8 HANDSHAKE_SERVER_HELLO               = 0x02; // Similar to client_hello, but one cipher only etc.
    const u8 HANDSHAKE_SERVER_CERTIFICATE         = 0x0b; // Contains chain of public key certificates from server.
    const u8 HANDSHAKE_SERVER_KEY_EXCHANGE        = 0x0c; // Keys exchange algorithm parameters (optional for RSA-only)
    const u8 HANDSHAKE_SERVER_CERTIFICATE_REQUEST = 0x0d; // From server to client to request client certificate
    const u8 HANDSHAKE_SERVER_HELLO_DONE          = 0x0e; // Finishes server part of handshake negotiation... done if using RSA only, but more messages later if using empheral keys (ECDHE etc.).
    const u8 HANDSHAKE_CERTIFICATE_VERIFY         = 0x0f; // Similar to SERVER_KEY_EXCHANGE, optional (depending on key exchange method)
    const u8 HANDSHAKE_CLIENT_KEY_EXCHANGE        = 0x10; // Client sends private key using RSA public key of server.
    const u8 HANDSHAKE_FINISHED                   = 0x14; // Indicates handshake is done, sent encrypted because CHANGE_CIPHER message should be sent before this.

    // Limits
    const u64 MAX_MSG_SIZE          = 16384; // 16 kb
    const u64 MIN_BUFFER_SIZE       = 16484; // 16 kb + 100 bytes
    const u64 HEADER_SIZE           = 5; // 1 + 2 + 2
    const u64 HANDSHAKE_HEADER_SIZE = 4; // 1 + 3
    const u64 MAX_APP_DATA_SIZE     = 16384; // 16 kb
    const u64 HMAC_BLOCK_SIZE       = 64;
    const u64 PREMASTER_SECRET_SIZE = 48; // for TLS 1.2

    // Global 
    shared X509TrustStore x509TrustStore = null;
    shared ByteArray macTempBuffer();
    shared ByteArray innerHashInput();
    shared ByteArray outerHashInput();

    // Get the default X509TrustStore.
    shared X509TrustStore getTrustStore()
    {
        if(TLS:x509TrustStore == null)
            TLS:x509TrustStore = X509TrustStore(true);

        return TLS:x509TrustStore;
    }

    // Human readable form.
    shared String<u8> getRecordName(u8 recordID)
    {
        if(recordID == RECORD_TYPE_CHANGE_CIPHER)
            return "RECORD_TYPE_CHANGE_CIPHER";
        if(recordID == RECORD_TYPE_ALERT)
            return "RECORD_TYPE_ALERT";
        if(recordID == RECORD_TYPE_HANDSHAKE)
            return "RECORD_TYPE_HANDSHAKE";
        if(recordID == RECORD_TYPE_APP_DATA)
            return "RECORD_TYPE_APP_DATA";

        return "UNKNOWN RECORD MSG, id: " + String<u8>:formatNumber(recordID);
    }

    // Human readable form.
    shared String<u8> getHandshakeRecordName(u8 recordID)
    {
        if(recordID == HANDSHAKE_SERVER_RESTART)
            return "HANDSHAKE_SERVER_RESTART";
        if(recordID == HANDSHAKE_CLIENT_HELLO)
            return "HANDSHAKE_CLIENT_HELLO";
        if(recordID == HANDSHAKE_SERVER_HELLO)
            return "HANDSHAKE_SERVER_HELLO";
        if(recordID == HANDSHAKE_SERVER_CERTIFICATE)
            return "HANDSHAKE_SERVER_CERTIFICATE";
        if(recordID == HANDSHAKE_SERVER_KEY_EXCHANGE)
            return "HANDSHAKE_SERVER_KEY_EXCHANGE";
        if(recordID == HANDSHAKE_SERVER_CERTIFICATE_REQUEST)
            return "HANDSHAKE_SERVER_CERTIFICATE_REQUEST";
        if(recordID == HANDSHAKE_SERVER_HELLO_DONE)
            return "HANDSHAKE_SERVER_HELLO_DONE";
        if(recordID == HANDSHAKE_CERTIFICATE_VERIFY)
            return "HANDSHAKE_CERTIFICATE_VERIFY";
        if(recordID == HANDSHAKE_CLIENT_KEY_EXCHANGE)
            return "HANDSHAKE_CLIENT_KEY_EXCHANGE";
        if(recordID == HANDSHAKE_FINISHED)
            return "HANDSHAKE_FINISHED";

        return "UNKNOWN HANDSHAKE MSG";
    }

    // Human readable form.
    shared String<u8> getCipherStr(u8 cipherID)
    {
        if(cipherID == CIPHER_NULL)
            return "null";

        if(cipherID == CIPHER_RSA_AES128_CBC_SHA)
            return "RSA_AES128_CBC_SHA";
        if(cipherID == CIPHER_RSA_AES256_CBC_SHA)
            return "RSA_AES256_CBC_SHA";
        if(cipherID == CIPHER_RSA_AES128_CBC_SHA256)
            return "RSA_AES128_CBC_SHA256";
        if(cipherID == CIPHER_RSA_AES128_CBC_SHA256)
            return "RSA_AES128_CBC_SHA256";
        if(cipherID == CIPHER_RSA_AES128_GCM_SHA256)
            return "RSA_AES128_GCM_SHA256";
        if(cipherID == CIPHER_RSA_AES256_GCM_SHA384)
            return "RSA_AES256_GCM_SHA384";

        if(cipherID == CIPHER_DHE_RSA_AES128_CBC_SHA)
            return "DHE_RSA_AES128_CBC_SHA";
        if(cipherID == CIPHER_DHE_RSA_AES256_CBC_SHA)
            return "DHE_RSA_AES256_CBC_SHA";
        if(cipherID == CIPHER_DHE_RSA_AES128_CBC_SHA256)
            return "DHE_RSA_AES128_CBC_SHA256";
        if(cipherID == CIPHER_DHE_RSA_AES256_CBC_SHA256)
            return "DHE_RSA_AES256_CBC_SHA256";
        if(cipherID == CIPHER_DHE_RSA_AES128_GCM_SHA256)
            return "DHE_RSA_AES128_GCM_SHA256";
        if(cipherID == CIPHER_DHE_RSA_AES256_GCM_SHA384)
            return "DHE_RSA_AES256_GCM_SHA384";

        if(cipherID == CIPHER_ECDHE_RSA_AES128_CBC_SHA)
            return "ECDHE_RSA_AES128_CBC_SHA";
        if(cipherID == CIPHER_ECDHE_RSA_AES256_CBC_SHA)
            return "ECDHE_RSA_AES256_CBC_SHA";
        if(cipherID == CIPHER_ECDHE_RSA_AES128_CBC_SHA256)
            return "ECDHE_RSA_AES128_CBC_SHA256";
        if(cipherID == CIPHER_ECDHE_RSA_AES128_GCM_SHA256)
            return "ECDHE_RSA_AES128_GCM_SHA256";
        if(cipherID == CIPHER_ECDHE_RSA_AES256_GCM_SHA384)
            return "ECDHE_RSA_AES256_GCM_SHA384";

        return "";
    }

    // Human readable from alert code.
    shared String<u8> getAlertStr(u8 alertID)
    {
        if(alertID == TLS:ALERT_CLOSE_NOTIFY)
            return "Close notify.";
        if(alertID == TLS:ALERT_UNEXPECTED_MSG)
            return "Unexpected message.";
        if(alertID == TLS:ALERT_BAD_RECORD_MAC)
            return "Bad record MAC.";
        if(alertID == TLS:ALERT_DECRYPT_FAIL_RESERVED)
            return "Decrypt failed.";
        if(alertID == TLS:ALERT_RECORD_OVERFLOW)
            return "Record overflow.";
        if(alertID == TLS:ALERT_DECOMPRESS_FAIL)
            return "Decompress fail.";
        if(alertID == TLS:ALERT_HANDSHAKE_FAIL)
            return "Handshake fail.";
        if(alertID == TLS:ALERT_NO_CERT_RESERVED)
            return "No certificate.";
        if(alertID == TLS:ALERT_BAD_CERT)
            return "Bad certificate.";
        if(alertID == TLS:ALERT_UNSUPPORTED_CERT)
            return "Unsupported certificate.";
        if(alertID == TLS:ALERT_CERT_REVOKED)
            return "Certificate revoked.";
        if(alertID == TLS:ALERT_CERT_EXPIRED)
            return "Certificate expired.";
        if(alertID == TLS:ALERT_CERT_UNKNOWN)
            return "Unknown certificate.";
        if(alertID == TLS:ALERT_ILLEGAL_PARAM)
            return "Illegal parameter.";
        if(alertID == TLS:ALERT_UNKNOWN_CERT_AUTHORITY)
            return "Certificate authority unknown.";
        if(alertID == TLS:ALERT_ACCESS_DENIED)
            return "Access denied.";
        if(alertID == TLS:ALERT_DECODE_ERROR)
            return "Decode error.";
        if(alertID == TLS:ALERT_DECRYPT_ERROR)
            return "Decryption error.";
        if(alertID == TLS:ALERT_EXPORT_RESTRICT_RESERVED)
            return "Export restricted.";
        if(alertID == TLS:ALERT_PROTOCOL_VERSION)
            return "Protocol version error.";
        if(alertID == TLS:ALERT_GARBAGE_SECURITY)
            return "Poor cipher security.";
        if(alertID == TLS:ALERT_INTERNAL_ERROR)
            return "Internal error.";
        if(alertID == TLS:ALERT_BAD_FALLBACK)
            return "Bad fallback.";
        if(alertID == TLS:ALERT_USER_HAD_LEFT_THE_CHAT)
            return "User has left the chat.";
        if(alertID == TLS:ALERT_NO_RENEGOTIATION)
            return "No renegotiation.";
        if(alertID == TLS:ALERT_UNKNOWN_EXTENSION)
            return "Unknown extension.";
        if(alertID == TLS:ALERT_NO_ERROR)
            return "No error.";

        return "";
    }

    // Get default allowed ciphers.
    shared u16[] getDefaultCiphers()
    {
        u16[] ciphers = u16[](1);
        ciphers[0] = TLS:CIPHER_RSA_AES128_CBC_SHA; // this is the only mandatory cipher in TLS 1.2
        return ciphers;

        //return u16[](TLS:CIPHER_RSA_AES128_CBC_SHA, TLS:CIPHER_RSA_AES256_CBC_SHA);
    }

    // Returns one of Hashing:HASH_NULL, Hashing:HASH_SHA1, Hashing:HASH_SHA256, Hashing:HASH_SHA384, Hashing:HASH_SHA512 etc.
    shared u8 getHashFuncType(u16 cipherMode)
    {

        if(cipherMode == TLS:CIPHER_RSA_AES128_CBC_SHA       || cipherMode == TLS:CIPHER_RSA_AES256_CBC_SHA       ||
           cipherMode == TLS:CIPHER_DHE_RSA_AES128_CBC_SHA   || cipherMode == TLS:CIPHER_DHE_RSA_AES256_CBC_SHA   ||
           cipherMode == TLS:CIPHER_ECDHE_RSA_AES128_CBC_SHA || cipherMode == TLS:CIPHER_ECDHE_RSA_AES256_CBC_SHA)
        {
            return Hashing:HASH_SHA1;
        }
        else if(cipherMode == TLS:CIPHER_RSA_AES128_CBC_SHA256       || cipherMode == TLS:CIPHER_RSA_AES256_CBC_SHA256     ||
                cipherMode == TLS:CIPHER_RSA_AES128_GCM_SHA256       || cipherMode == TLS:CIPHER_DHE_RSA_AES128_CBC_SHA256 ||
                cipherMode == TLS:CIPHER_DHE_RSA_AES256_CBC_SHA256   || cipherMode == TLS:CIPHER_DHE_RSA_AES128_GCM_SHA256 ||
                cipherMode == TLS:CIPHER_ECDHE_RSA_AES128_CBC_SHA256 || cipherMode == TLS:CIPHER_ECDHE_RSA_AES128_GCM_SHA256)
        {
            return Hashing:HASH_SHA256;
        }
        // SHA384 CIPHER_RSA_AES256_GCM_SHA384 CIPHER_DHE_RSA_AES256_GCM_SHA384 CIPHER_ECDHE_RSA_AES256_GCM_SHA384

        return Hashing:HASH_NULL; // unknown
    }

    // Returns one of AES:STRENGTH_128 or AES:STRENGTH_256 or AES:STRENGTH_UNKNOWN if error.
    shared u8 getAESStrength(u16 cipherMode)
    {
        if(cipherMode == TLS:CIPHER_RSA_AES128_CBC_SHA          || cipherMode == TLS:CIPHER_RSA_AES128_CBC_SHA256       ||
           cipherMode == TLS:CIPHER_RSA_AES128_GCM_SHA256       || cipherMode == TLS:CIPHER_DHE_RSA_AES128_CBC_SHA      ||
           cipherMode == TLS:CIPHER_DHE_RSA_AES128_CBC_SHA256   || cipherMode == TLS:CIPHER_DHE_RSA_AES128_GCM_SHA256   ||
           cipherMode == TLS:CIPHER_ECDHE_RSA_AES128_CBC_SHA    || cipherMode == TLS:CIPHER_ECDHE_RSA_AES128_CBC_SHA256 ||
           cipherMode ==  TLS:CIPHER_ECDHE_RSA_AES128_GCM_SHA256)
        {
            return AES:STRENGTH_128;
        }
        else if(cipherMode == TLS:CIPHER_RSA_AES256_CBC_SHA        || cipherMode == TLS:CIPHER_RSA_AES256_CBC_SHA256      || 
                cipherMode == TLS:CIPHER_RSA_AES256_GCM_SHA384     || cipherMode == TLS:CIPHER_DHE_RSA_AES256_CBC_SHA     || 
                cipherMode == TLS:CIPHER_DHE_RSA_AES256_CBC_SHA256 || cipherMode == TLS:CIPHER_DHE_RSA_AES256_GCM_SHA384  || 
                cipherMode == TLS:CIPHER_ECDHE_RSA_AES256_CBC_SHA  || cipherMode == TLS:CIPHER_ECDHE_RSA_AES256_GCM_SHA384)
        {
            return AES:STRENGTH_256;
        }

        return AES:STRENGTH_UNKNOWN; // unknown
    }
    
    // Hashed Message Authentication Cryptography. Returns message digest (based on hashing and xor operations). See RFC 2104.
    shared u8[64] hmac(u8[] key, u8[] text, u64 numTextBytes, u8 hashFuncType)
    {
        u8[64] zeroRet;

        if(text == null || key == null)
            return zeroRet; // unsupported
        
        if(hashFuncType != Hashing:HASH_SHA1 && hashFuncType != Hashing:HASH_SHA256)
            return zeroRet; // unsupported

        // Psuedo code form wikipedia: https://en.wikipedia.org/wiki/HMAC
        //      function hmac is
        //  input:
        //      key:        Bytes     // Array of bytes
        //      message:    Bytes     // Array of bytes to be hashed
        //      hash:       Function  // The hash function to use (e.g. SHA-1)
        //      blockSize:  Integer   // The block size of the underlying hash function (e.g. 64 bytes for SHA-1)
        //      outputSize: Integer   // The output size of the underlying hash function (e.g. 20 bytes for SHA-1)
        //
        //  // Keys longer than blockSize are shortened by hashing them
        //  if(length(key) > blockSize) then
        //     key ← hash(key) // Key becomes outputSize bytes long
        //
        //  // Keys shorter than blockSize are padded to blockSize by padding with zeros on the right
        //  if(length(key) < blockSize) then
        //      key ← Pad(key, blockSize) // Pad key with zeros to make it blockSize bytes long
        //
        //  o_key_pad ← key xor [0x5c * blockSize]   // Outer padded key
        //  i_key_pad ← key xor [0x36 * blockSize]   // Inner padded key
        //  return hash(o_key_pad ∥ hash(i_key_pad ∥ message)) // Where ∥ is concatenation

        // key smaller than blocksize? pad with zero
        if(key.length() < HMAC_BLOCK_SIZE)
        {
            u8[] oldKey = key;
            key = u8[](HMAC_BLOCK_SIZE);

            for(u64 k=0; k<oldKey.length(); k++)
                key[k] = oldKey[k];

            for(u64 i=oldKey.length(); i<HMAC_BLOCK_SIZE; i++)
                key[i] = 0;
        }

        // Key larger than blocksize? use hash to shorten
        if(key.length() > HMAC_BLOCK_SIZE)
        {
            key = Hashing:hash(key, hashFuncType);
        }

        // Magic XOR padding
        if(innerHashInput.getAllocatedSize() < HMAC_BLOCK_SIZE)
            innerHashInput.resize(HMAC_BLOCK_SIZE + numTextBytes);
        if(outerHashInput.getAllocatedSize() < HMAC_BLOCK_SIZE)
            outerHashInput.resize(HMAC_BLOCK_SIZE + numTextBytes);

        innerHashInput.numUsed = HMAC_BLOCK_SIZE;
        innerHashInput.index   = HMAC_BLOCK_SIZE;

        outerHashInput.numUsed = HMAC_BLOCK_SIZE;
        outerHashInput.index   = HMAC_BLOCK_SIZE;

        for(u64 i=0; i<key.length(); i++)
        {
            innerHashInput[i] = key[i] ^ 0x36; // 0x36 is magic value from RFC 2104
            outerHashInput[i] = key[i] ^ 0x5c; // 0x5c is magic value from RFC 2104
        }

        // Next: hash(o_key_pad ∥ hash(i_key_pad ∥ message)) // Where ∥ is concatenation

        // concat inner input
        innerHashInput.write(text, numTextBytes);

        u8[64] res;
        if(hashFuncType == Hashing:HASH_SHA1)
        {
            u8[20] innerHashRes = Hashing:hashSHA1(innerHashInput);
            for(u64 h=0; h<20; h++)
                outerHashInput.writeU8(innerHashRes[h]);
            u8[20] finalHashRes = Hashing:hashSHA1(outerHashInput);

            for(u64 f=0; f<20; f++)
                res[f] = finalHashRes[f];
        }
        else if(hashFuncType == Hashing:HASH_SHA256)
        {
            u8[32] innerHashRes32 = Hashing:hashSHA256(innerHashInput);
            for(u64 h=0; h<32; h++)
                outerHashInput.writeU8(innerHashRes32[h]);
            u8[32] finalHashRes32 = Hashing:hashSHA256(outerHashInput);

            for(u64 f=0; f<32; f++)
                res[f] = finalHashRes32[f];
        }
        else
        {
            assert(false); // TODO
        }
        
        return res;
    }

    // Hashed Message Authentication Cryptography. Returns message digest (based on hashing and xor operations). See RFC 2104.
    shared u8[] hmacArray(u8[] key, u8[] text, u64 numTextBytes, u8 hashFuncType)
    {
        u8[] a = null;
        u8[64] res = hmac(key, text, numTextBytes, hashFuncType);
        if(hashFuncType == Hashing:HASH_SHA1)
        {
            a = u8[](20);
            for(u64 i=0; i<20; i++)
                a[i] = res[i];
        }
        else if(hashFuncType == Hashing:HASH_SHA256)
        {
            a = u8[](32);
            for(u64 i=0; i<32; i++)
                a[i] = res[i];
        }

        return a;
    }

    // Expand data (aka key data) to arbitrary length using hmac.
    shared u8[] prfExpand(u8[] secret, u8[] seed, u64 numExpandedBytes)
    {
        // From RFC 5246
        // we define a data expansion function, P_hash(secret, data),
        // that uses a single hash function to expand a secret and seed into an
        // arbitrary quantity of output:
        //P_hash(secret, seed) = HMAC_hash(secret, A(1) + seed) +
        //                       HMAC_hash(secret, A(2) + seed) +
        //                       HMAC_hash(secret, A(3) + seed) + ...
        //
        // where + indicates concatenation.
        //
        // A() is defined as:
        // A(0) = seed
        // A(i) = HMAC_hash(secret, A(i-1))

        u64 blockSize = 64;
        ByteArray result(numExpandedBytes + blockSize);

        u8[] a0    = seed.clone();
        u8[] a1    = TLS:hmacArray(secret, a0, a0.length(), Hashing:HASH_SHA256);
        u8[] aPrev = a1;

        while(result.numUsed < numExpandedBytes)
        {
            // Q = A(N-1) + seed
            ByteArray tempInput(aPrev);
            tempInput.index = aPrev.length();
            tempInput.write(seed);

            // HMAC_hash(secret, Q)
            u8[] aR = TLS:hmacArray(secret, tempInput.data, tempInput.size(), Hashing:HASH_SHA256);

            // append to result
            result.write(aR);

            aPrev = TLS:hmacArray(secret, aPrev, aPrev.length(), Hashing:HASH_SHA256);
        }

        u8[] exact(numExpandedBytes);
        for(u64 x=0; x<numExpandedBytes; x++)
            exact[x] = result.data[x];

        return exact;
    }

    // "PRF" Pseudo Random Function
    shared u8[] prf(u8[] secret, u8[] label, u8[] seed, u64 numBytesToGen)
    {
        // PRF(secret, label, seed) = SHA256(secret, label + seed)
        // secret is key
        // label : as defined in RFC
        // seed : seed used by expansion functions
        // numBytes : number of bytes length to generate

        ByteArray input(label);
        input.index = label.length();
        input.write(seed);

        return TLS:prfExpand(secret, input.toArray(), numBytesToGen);
    }

    // Hashed Message Auth Code (MAC) for a TLS messages. payloadBytes = unencrypted payload bytes. Number of valid bytes returned depends on hashFuncType, minimum 20.
    shared u8[64] calcMsgMAC(u8 hashFuncType, u8[] key, u64 seqNum, u8 recordType, u16 recordLength, ByteArray payloadBytes)
    {
        // From TLS 1.2 RFC 5246 section-6.2.3.1 where "+" denotes concatenation.
        // HMAC(MAC_write_key, seq_num + TLSCompressed.type + TLSCompressed.version + TLSCompressed.length + TLSCompressed.fragment);
        //
        // The fields meaning (like many things in the TLS RFCs) aren't specified clearly, but from https://stackoverflow.com/questions/31009358/tls-mac-message-verification and other sources :
        //
        // seq_num:
        // Description: A int counter, starting in 0, which will be incremented every frame received or sended. For a TCP Session, two seq_numbers must be used, one for the server and other for the client, incrementing everytime each of them sends a frame.
        // Representation: This value must be represented as Unsigned Long Long with 8 bytes
        //
        // TLSCompressed.type
        // Description: This field is extracted from TLS Record layer (the encrypted payload). For example, if it's an Application Data frame, we must use 0x17. If handshake msg use 0x16.
        // Representation: This value must be represented as unsigned byte, with 1 bytes.
        //
        // TLSCompressed.version
        // Description: This field is also extracted from TLS Record layer (the encrypted payload). For example, if the frame is transferred using TLS 1.2, we must use it's hex representation 0x0303.
        // Representation: This value must be represented as Unsigned Short, with 2 bytes.
        //
        // TLSCompressed.length
        // Description: This field represents the actual length of the decrypted payload.
        // Representation: This value must be represented as Unsigned Short, with 2 bytes.
        //
        // TLSCompressed.fragment
        // Description: This field is the actual **decrypted payload.
        //

        macTempBuffer.clear();
        macTempBuffer.setBigEndian();
        macTempBuffer.writeU64(seqNum);
        macTempBuffer.writeU8(recordType);
        macTempBuffer.writeU16(0x0303); // TLS 1.2
        macTempBuffer.writeU16(recordLength);
        macTempBuffer.write(payloadBytes);

        return TLS:hmac(key, macTempBuffer.data, macTempBuffer.size(), hashFuncType);
    }

    // Generate randoms
    shared u8[] generateTrueRandomBytes(u64 numBytes)
    {
        u8[] b(numBytes);

        u64 r = System:getTrueRandom();
        for(u64 i=0; i<numBytes; i++)
        {
            b[i] = u8((r >> ((i % 8) * 8)) & 0x00000000000000FF);

            if((i % 8) == 0)
                r = System:getTrueRandom();
        }

        return b;
    }

    // Generate premaster secret 48 bytes
    shared u8[] generatePremasterSecret()
    {
        u8[] preMasterSecret = u8[](48);

        for(u64 x=0; x<6; x++)
        {
            u64 r = System:getTrueRandom();

            for(u64 b=0; b<8; b++)
                preMasterSecret[(x * 8) + b] = u8((r >> (b * 8)) & 0x00000000000000FF);
        }

        // first two bytes are not random, but verify the TLS version (to help prevent roll-back attacks).
        preMasterSecret[0] = 0x03; // SSL 3,3 == TLS 1,2
        preMasterSecret[1] = TLS:VER_1_2;

        return preMasterSecret;
    }

    // Generate master secret from premaster secret
    shared u8[] generateMasterSecret(u8[] clientRandoms, u8[] serverRandoms, u8[] preMasterSecret)
    {
        if(clientRandoms == null || serverRandoms == null || preMasterSecret == null)
            return null;

        // RFC 5246 Section 8.1. - Computing the Master Secret
        //
        // For all key exchange methods, the same algorithm is used to convert
        // the pre_master_secret into the master_secret.  The pre_master_secret
        // should be deleted from memory once the master_secret has been
        // computed.
        // master_secret = PRF(pre_master_secret, "master secret", ClientHello.random + ServerHello.random) [0..47];
        //
        // The master secret is always exactly 48 bytes in length.  The length
        // of the premaster secret will vary depending on key exchange method.

        u8[] msLabel(Chars:m, Chars:a, Chars:s, Chars:t, Chars:e, Chars:r, Chars:SPACE, Chars:s, Chars:e, Chars:c, Chars:r, Chars:e, Chars:t); //"master secret";
        u8[] msSeed(clientRandoms.length() + serverRandoms.length()); // client and server random bytes

        for(u64 c=0; c<clientRandoms.length(); c++)
            msSeed[c] = clientRandoms[c];
        for(u64 s=0; s<serverRandoms.length(); s++)
            msSeed[clientRandoms.length() + s] = serverRandoms[s];

        u8[] masterSecret = TLS:prf(preMasterSecret, msLabel, msSeed, 48);

        return masterSecret;
    }

    // Generate symetric encryption keys from master secret
    shared TLSKeys generateKeysFromMasterSecret(u16 cipherMode, u8[] clientRandoms, u8[] serverRandoms, u8[] masterSecret)
    {
        if(clientRandoms == null || serverRandoms == null || masterSecret == null)
            return null;

        // RFC 5246 Section 6.3 - Key Calculation
        // The master secret is expanded into a sequence of secure bytes, which
        // is then split to a client write MAC key, a server write MAC key, a
        // client write encryption key, and a server write encryption key.  Each
        // of these is generated from the byte sequence in that order.  Unused
        // values are empty.  Some AEAD ciphers may additionally require a
        // client write IV and a server write IV (see Section 6.2.3.3).
        // 
        // When keys and MAC keys are generated, the master secret is used as an
        // entropy source.
        // 
        // To generate the key material, compute
        // 
        //     key_block = PRF(SecurityParameters.master_secret,
        //                     "key expansion",
        //                     SecurityParameters.server_random +
        //                     SecurityParameters.client_random);
        // 
        // until enough output has been generated.  Then, the key_block is
        // partitioned as follows:
        // 
        //     client_write_MAC_key[SecurityParameters.mac_key_length]
        //     server_write_MAC_key[SecurityParameters.mac_key_length]
        //     client_write_key[SecurityParameters.enc_key_length]
        //     server_write_key[SecurityParameters.enc_key_length]
        //     client_write_IV[SecurityParameters.fixed_iv_length]
        //     server_write_IV[SecurityParameters.fixed_iv_length]
        
        u8[] msLabel(Chars:k, Chars:e, Chars:y, Chars:SPACE, Chars:e, Chars:x, Chars:p, Chars:a, Chars:n, Chars:s, Chars:i, Chars:o, Chars:n); //"key expansion";
        
        // Swap the client and server random values:
        // Master Secret generatation is client+server (RFC 5246 8.1)
        // Keys generation is server+client (RFC 5246 6.3)
        
        u8[] msSeed(serverRandoms.length() + clientRandoms.length()); // client and server random bytes
        for(u64 s=0; s<serverRandoms.length(); s++)
            msSeed[s] = serverRandoms[s];
        for(u64 c=0; c<clientRandoms.length(); c++)
            msSeed[serverRandoms.length() + c] = clientRandoms[c];

        u8[] keysData = TLS:prf(masterSecret, msLabel, msSeed, 256); // 256 bytes is enough for 8 256-bit keys

        u64 keySize = 16; // AES-128 is 128 bits (AKA 16 bytes)
        if(TLS:getAESStrength(cipherMode) == AES:STRENGTH_256)
            keySize = 32;

        u64 hmacKeySize = 20; // SHA-1 is 160 bits (AKA 20 bytes)
        if(TLS:getHashFuncType(cipherMode) == Hashing:HASH_SHA256)
            hmacKeySize = 32; // SHA-256 is 256 bits (AKA 32 bytes)

        TLSKeys keys();

        u64 ki = 0;
        keys.clientKeyMAC = keysData.subset(ki, ki + hmacKeySize - 1);
        ki += hmacKeySize;
        keys.serverKeyMAC = keysData.subset(ki, ki + hmacKeySize - 1);
        ki += hmacKeySize;
        keys.clientKey = keysData.subset(ki, ki + keySize - 1);
        ki += keySize;
        keys.serverKey = keysData.subset(ki, ki + keySize - 1);
        ki += keySize;

        return keys;
    }

    // Generate a true random initialization vector.
    shared u8[16] generateIV()
    {
        u64 r0 = System:getTrueRandom();
        u64 r1 = System:getTrueRandom();
        u8[16] iv;
        for(u8 i=0; i<8; i++)
        {
            iv[i] = u8(r0 >> (i * 8));
        }
        for(u8 i=0; i<8; i++)
        {
            iv[8 + i] = u8(r1 >> (i * 8));
        }

        return iv;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// TLSClient
////////////////////////////////////////////////////////////////////////////////////////////////////

// Client connection. Wraps TCP socket. Supports TLS 1.2 only. Implements ISocket interface so it
// can be used as a drop-in replacement for normal socket operations. Each TLSClient uses a few
// hundred KB of memory (minimum).
class TLSClient implements ISocket
{
    // State of client connection
    const u8 STATE_CONNECTING         = 0;   // Waiting for TCP connection etc.
    const u8 STATE_HELLO_SENT         = 1;   // client sent hello, waiting for hello response from server.
    const u8 STATE_GOT_SERVER_HELLO   = 2;   // Server said hello, provides cipher choice
    const u8 STATE_GOT_SERVER_CERTS   = 3;   // Server provided certificates (X509)
    const u8 STATE_SENT_VERIFY        = 4;   // Client sent verify msg to server
    const u8 STATE_ALL_ENCRYPTED      = 5;   // We have recv'd CHANGE_CIPHER_SPEC msg from server
    const u8 STATE_APP_DATA           = 6;   // We have recv'd HANDSHAKE_FINISHED msg from server 
    const u8 STATE_WAIT_TO_DISCONNECT = 100; // If the server provides bad handshake, bad MAC etc. we always kill the connection at the same time to mitigate timing attacks
    const u8 STATE_DISCONNECT_CLIENT  = 253; // Disconnect by client
    const u8 STATE_DISCONNECT_SERVER  = 254; // Disconnect by server
    const u8 STATE_ERROR              = 255; // Fatal error

    const f64 DISCONNECT_WAIT_TIME = 5000.0; // N milliseconds from the last message receieved (if error triggered)

    TCPSocket socket; // to server
    u16[] allowedCiphers = null; // allowed ciphers to be ordered from least secure to most secure (or most preferred)
    u8   tlsVer       = TLS:VER_1_2;     // version we agree to use, must be 1.2
    u16  cipherMode   = TLS:CIPHER_NULL; // agreed upon cipher suite to use for connection
    u8   state        = 0; // one of STATE_CONNECTING etc.
    u64  clientSeqNum = 0; // Each TLS record sent by the client causes this to increment 1. Used in MAC.
    u64  serverSeqNum = 0; // Each TLS record sent by the server causes this to increment 1. Used in MAC.
    u8[] serverRandoms;    // 28 bytes, or 32 including time at start
    u8[] clientRandoms;    // 28 bytes, or 32 including time at start
    u8[] preMasterSecret;  // 48 bytes for RSA
    u8[] masterSecret;     // 48 bytes for all key exchange methods
    TLSKeys keys;          // final connection keys
    AES clientEncrypter;   // could be CBC or CTR mode.
    AES serverDecrypter;   // could be CBC or CTR mode.
    ArrayList<X509Certificate> serverCerts(); // from server, [0] is server, [n] is top level certificate authority
    ByteArray handshakeMsgs(1024); // for verification data calculation
    RSAPublicKey rsaPublicKey; // from server
    f64 disconnectTime; // when we should disconnect
    ByteArray sendBuffer(TLS:MIN_BUFFER_SIZE); // For raw TCP socket send.
    ByteArray recvBuffer(TLS:MIN_BUFFER_SIZE); // For raw TCP socket recv.
    ByteArray encryptBuffer(TLS:MIN_BUFFER_SIZE); // Intermediate buffer for encrypting
    ByteArray decryptBuffer(TLS:MIN_BUFFER_SIZE); // Intermediate buffer for decrypting
    ByteArray sendAppBuffer(TLS:MIN_BUFFER_SIZE); // Application data send (decrypted). This is the only data users of TLSClient send.
    ByteArray recvAppBuffer(TLS:MIN_BUFFER_SIZE); // Application data recv (decrypted). This is the only data users of TLSClient recv.
    bool debugLogging = true; // debugging, if true, logs connection info

    // Create client wrapping TCP ssocket.
    void constructor(TCPSocket socket)
    {
        this.socket = socket;
        this.state  = STATE_CONNECTING;

        this.sendBuffer.setBigEndian(); // network byte order for TLS
        this.recvBuffer.setBigEndian(); // network byte order for TLS

        this.allowedCiphers = TLS:getDefaultCiphers();

        this.disconnectTime = System:getTime() + DISCONNECT_WAIT_TIME;
    }

    // Create client wrapping TCP ssocket. allowedCiphers=null will use default ones. bufferSizeBytes for message queue send and recv.
    void constructor(TCPSocket socket, u16[] allowedCiphers, u32 bufferSizeBytes)
    {
        this.socket = socket;
        this.state  = STATE_CONNECTING;

        if(bufferSizeBytes < (TLS:MAX_MSG_SIZE * 2)) // 32 KB lower bound
            bufferSizeBytes = 2 * TLS:MAX_MSG_SIZE;

        this.sendBuffer = ByteArray(bufferSizeBytes);
        this.recvBuffer = ByteArray(bufferSizeBytes);

        this.sendBuffer.setBigEndian(); // network byte order for TLS
        this.recvBuffer.setBigEndian(); // network byte order for TLS

        if(allowedCiphers == null)
        {
            this.allowedCiphers = TLS:getDefaultCiphers();
        }

        this.disconnectTime = System:getTime() + DISCONNECT_WAIT_TIME;
    }

    // [ISocket] Get address we are bound to (local machine). Applies for all sockets.
	IPAddress getSourceIP();

	// [ISocket] Get address we are connected to. Does not apply for TCP listen() sockets.
	IPAddress getDestinationIP();

	// [ISocket] Connecting, Disconnected etc. See SocketState for values.
	u8 getState()
    {
        if(socket == null)
            return 0;

        return socket.getState();
    }

	// [ISocket] Send data via socket.
	bool send(u8[] data, u32 numBytes)
    {
        return sendAppData(data, 0, numBytes);
    }

	// [ISocket] Send data via socket.
	bool send(u8[] data, u32 dataStartIndex, u32 numBytes)
    {
        return sendAppData(data, dataStartIndex, numBytes);
    }

	// [ISocket] Send data via socket. toIP parameter applies to UDP only, ignored by TCP.
	bool send(u8[] data, u32 numBytes, IPAddress toIP)
    {
        return sendAppData(data, 0, numBytes);
    }

	// [ISocket] Send data via socket. toIP parameter applies to UDP only, ignored by TCP.
	bool send(u8[] data, u32 dataStartIndex, u32 numBytes, IPAddress toIP)
    {
        return sendAppData(data, dataStartIndex, numBytes);
    }

	// [ISocket] Receive data from socket into data.
	u32 receive(u8[] data)
    {
        return receive(data, 0);
    }

	// [ISocket] Receive data from socket.
	u32 receive(u8[] data, u32 dataStartIndex)
    {
        update();

        if(recvAppBuffer == null)
            return 0;

        if(recvAppBuffer.size() == 0)
            return 0;

        if(dataStartIndex >= data.length())
            return 0;

        u64 numBytes = Math:min(recvAppBuffer.size(), data.length() - dataStartIndex);

        for(u64 b=0; b<numBytes; b++)
        {
            data[dataStartIndex + b] = recvAppBuffer.data[b];
        }

        recvAppBuffer.remove(0, numBytes);

        return numBytes;
    }

	// [ISocket] Receive data from socket. outIP parameter applies to UDP only, ignored by TCP.
	u32 receive(u8[] data, IPAddress outIP)
    {
        return receive(data, 0);
    }

	// [ISocket] Receive data from socket. outIP parameter applies to UDP only, ignored by TCP.
	u32 receive(u8[] data, u32 dataStartIndex, IPAddress outIP)
    {
        return receive(data, dataStartIndex);
    }

    // Get buffer containing recv'd application data.
    ByteArray getAppRecvBuffer()
    {
        return recvAppBuffer;
    }

    // Send application data. Will be buffered until TLS connection established.
    bool sendAppData(u8[] appData, u64 index, u64 numBytes)
    {
        this.sendAppBuffer.write(appData, index, numBytes);
        update(); // will cause data to be sent right away if possible
        return true;
    }

	// [ISocket] Disconnect socket from destination.
	void disconnect()
    {
        if(socket == null)
            return;

        socket.disconnect();
        socket = null;

        this.state = STATE_DISCONNECT_CLIENT;
    }

    // State ID, one of STATE_
    u8 getTLSState()
    {
        return this.state;
    }

    // State String, one of STATE_
    String<u8> getTLSStateName()
    {
        if(this.state == STATE_CONNECTING)
            return "STATE_CONNECTING";
        else if(this.state == STATE_HELLO_SENT)
            return "STATE_HELLO_SENT";
        else if(this.state == STATE_GOT_SERVER_HELLO)
            return "STATE_GOT_SERVER_HELLO";
        else if(this.state == STATE_GOT_SERVER_CERTS)
            return "STATE_GOT_SERVER_CERTS";
        else if(this.state == STATE_SENT_VERIFY)
            return "STATE_SENT_VERIFY";
        else if(this.state == STATE_ALL_ENCRYPTED)
            return "STATE_ALL_ENCRYPTED";
        else if(this.state == STATE_APP_DATA)
            return "STATE_APP_DATA";
        else if(this.state == STATE_WAIT_TO_DISCONNECT)
            return "STATE_WAIT_TO_DISCONNECT";
        else if(this.state == STATE_DISCONNECT_CLIENT)
            return "STATE_DISCONNECT_CLIENT";
        else if(this.state == STATE_DISCONNECT_SERVER)
            return "STATE_DISCONNECT_SERVER";
        else if(this.state == STATE_ERROR)
            return "STATE_ERROR";

        return "STATE_UNKNOWN";
    }

    // Internal logging 
    void logInfo(String<u8> msg)
    {
        if(debugLogging == false)
            return;

        Log:log(msg + "\n");
    }

    // Internal logging 
    void logError(String<u8> msg)
    {
        this.state = STATE_WAIT_TO_DISCONNECT;

        if(debugLogging == false)
            return;

        Log:log(msg + "\n");
    }

    // Update. Poll reguarly to process messages etc.
    void update()
    {
        if(this.state == STATE_ERROR || this.state == STATE_DISCONNECT_CLIENT || this.state == STATE_DISCONNECT_SERVER)
            return;

        if(state == STATE_WAIT_TO_DISCONNECT)
        {
            // just waiting
            if(this.disconnectTime < System:getTime())
            {
                state = STATE_ERROR; // we disconnected because of bad handshake or bad record MAC etc.
                if(socket != null)
                {
                    socket.disconnect();
                    socket = null;
                }
            }

            return;
        }

        // check TCP socket state first
        if(socket == null)
            return;

        if(socket.getState() == SocketState:CONNECTING)
			return; // wait...

        if(socket.getState() != SocketState:CONNECTED)
            return; // disconnected etc.

        // Recv any waiting data, process incomming messages
        updateRecv();

        // Update TLS connection state
        updateTLSState();
    }

    // Read data from TCP socket
    void updateRecv()
    {
        // receive data
        u32 numRecv = socket.receive(recvBuffer.data, recvBuffer.numUsed);
        recvBuffer.numUsed += numRecv;

        // check for complete message to process
        recvBuffer.index = 0;
        i32 numRead = readMsg(recvBuffer);
        if(numRead < 0)
        {
            logError("ERROR: Error reading message from server! Code: " + String<u8>:formatNumber(numRead));

            // error, close connection
            socket.disconnect();
            socket = null;
            return;
        }
        else if(numRead > 0)
        {
            recvBuffer.remove(0, numRead); // remove bytes of processed message
            recvBuffer.index = 0; // back to start
        }
        // else if(numRead == 0) // this is fine, just waiting for more data (partial message bytes)
    }

    // Update TLS connection state (as opposed to TCP)
    void updateTLSState()
    {
        // The process for connecting from client to server (RSA) is:
        // 1. TCP connection from client to server
        // 2. Client sends client hello msg to server
        // 3. Server responds with server hello msg
        // 4. Server sends certificate(s)
        // 5. Client responds with verify message
        // 6. Server responds with it's verify message
        // 7. Then in app data state
        
        if(this.state == STATE_CONNECTING)
        {
            // send hello
            this.writeClientHelloMsg(sendBuffer, TLS:VER_1_2, this.allowedCiphers);
            socket.send(sendBuffer.data, sendBuffer.numUsed);
            sendBuffer.clear();

            this.state = STATE_HELLO_SENT;
        }
        else if(this.state == STATE_HELLO_SENT)
        {
            // waiting for server hello response
        }
        else if(this.state == STATE_GOT_SERVER_HELLO)
        {
            // got hello response from server
        }
        else if(this.state == STATE_APP_DATA)
        {
            // check if we need to send app data
            while(sendAppBuffer.size() > 0)
            {
                u16 MAX_APP_BYTES = 1024; // Considering MTU and such, smaller packets are better for latency / avoiding fragmentation, also TLS msg has max 16 KB size.

                u16 numBytesToSend = MAX_APP_BYTES; 
                if(sendAppBuffer.size() < MAX_APP_BYTES)
                    numBytesToSend = sendAppBuffer.size();

                // encrypt and send
                this.writeAppDataMsg(sendBuffer, TLS:generateIV(), sendAppBuffer.data, 0, numBytesToSend);
                socket.send(sendBuffer.data, sendBuffer.numUsed);
                sendBuffer.clear();

                if(sendAppBuffer.size() < MAX_APP_BYTES)
                    sendAppBuffer.clear();
                else
                    sendAppBuffer.remove(0, MAX_APP_BYTES); // just remove first N bytes
            }
        }
    }

    // Read/parse msg. Returns 0 if not enough data in b yet (partial message). Returns -ve for error. Postive number is number of bytes in next message read.
    i32 readMsg(ByteArray b)
    {
        // TLS Packet:
        //
        // HEADER:
        // Byte 0: TLS Record Type
        // Byte 1-2: TLS VERSION (major, minor)
        // Byte 3-4: Length of data in the record, excluding implied header (16 KB max)
        //
        // RECORD: (varies)

        if(b == null)
            return -1;

        // record header minimum 5 bytes
        if(b.getNumBytesLeft() < 5)
            return 0;

        u32 msgStartIndex = b.index;

        u8 msgID        = b.readU8(); // TLS:RECORD_TYPE_HANDSHAKE etc.
        u8 majorVersion = b.readU8();
        u8 minorVersion = b.readU8();

        //logInfo("TLSClient.readMsg() msg: " + TLS:getRecordName(msgID));

        // Some servers will send messages (like alerts) as TLS 1.0 (3, 1). TLS real-world implementation is a fucking mess.
        //if(minorVersion != TLS:VER_1_2)
        //    return -2;

        u16 msgBodySize = u16(b.readU8()) << 8; // doesn't include header bytes (5)
        msgBodySize |= b.readU8();

        u32 totalMsgSize = (msgBodySize + TLS:HEADER_SIZE);
        if(totalMsgSize > b.numUsed)
        {
            b.index -= TLS:HEADER_SIZE; // go back
            return 0;
        }

        // IMPORTANT MITIGATION: We use a constant time offset to disconnect when entering an error state caused by a
        // bad msg from server. This is designed to thwart "timing" attacks because every bad record MAC or padding 
        // error sees exactly the same response from us.
        this.disconnectTime = System:getTime() + DISCONNECT_WAIT_TIME;

        // different record types
        if(msgID == TLS:RECORD_TYPE_ALERT)
        {   
            if(readAlertMsg(b) == false)
                return -1;
        }
        else if(msgID == TLS:RECORD_TYPE_CHANGE_CIPHER)
        {
            if(readCipherChangeMsg(b) == false)
                return -1;
        }
        else if(msgID == TLS:RECORD_TYPE_APP_DATA)
        {
            if(readAppDataMsg(b, msgBodySize) == false)
                return -1;
        }
        else if(msgID == TLS:RECORD_TYPE_HANDSHAKE) // this is ~10 msg types
        {
            if(b.getNumBytesLeft() < 4)
                return -6;

            if(this.state == STATE_ALL_ENCRYPTED)
            {
                // verify msg from server is encrypted unlike all other handshake msgs
                if(readHandshakeVerifyMsg(b, msgStartIndex, msgBodySize) == false)
                    return -1;
            }
            else
            {
                // another header, 4 bytes total
                u8  handshakeHeaderID = b.readU8();
                u32 handshakeBodySize = (u32(b.readU8()) << 16) | (u32(b.readU8()) << 8) | (u32(b.readU8()));

                //logInfo("TLSClient.readMsg() handshakeHeaderID: " + TLS:getHandshakeRecordName(handshakeHeaderID));

                if(handshakeHeaderID == TLS:HANDSHAKE_SERVER_RESTART)
                {
                    // we don't support and just ignore (which is acceptable, worse case server disconnects us)
                    serverSeqNum++;
                }
                else if(handshakeHeaderID == TLS:HANDSHAKE_SERVER_HELLO)
                {
                    if(readHandshakeServerHelloMsg(b, msgStartIndex, msgBodySize) == false)
                        return -1;
                }
                else if(handshakeHeaderID == TLS:HANDSHAKE_SERVER_CERTIFICATE)
                {
                    if(readHandshakeServerCertificateMsg(b, msgStartIndex, msgBodySize) == false)
                        return -1;
                }
                else if(handshakeHeaderID == TLS:HANDSHAKE_SERVER_CERTIFICATE_REQUEST)
                {
                    // not supported (server asks client for certificate)
                    logError("Unsupported handshakeHeaderID == TLS:HANDSHAKE_SERVER_CERTIFICATE_REQUEST");
                    serverSeqNum++;
                    return -1;
                }
                else if(handshakeHeaderID == TLS:HANDSHAKE_SERVER_KEY_EXCHANGE)
                {
                    // TODO DHE/ECDHE secondary key exchange etc.
                    logError("Unsupported handshakeHeaderID == TLS:HANDSHAKE_SERVER_KEY_EXCHANGE");
                    serverSeqNum++;
                    return -1;
                }
                else if(handshakeHeaderID == TLS:HANDSHAKE_SERVER_HELLO_DONE)
                {
                    if(readHandshakeServerDoneMsg(b, msgStartIndex, msgBodySize) == false)
                        return -1;
                }
            }
        }
        else
        {
            logError("Got unknown msg from server!");
            return -100; // don't know this message type
        }

        if(b.index < (msgStartIndex + totalMsgSize))
            b.index = (msgStartIndex + totalMsgSize); // could be extensions tacked on at end which we do not support

        return b.index;
    }

    // Read and process alert record.
    bool readAlertMsg(ByteArray b)
    {
        if(b.getNumBytesLeft() < 2)
        {
            logError("Alert msg too small.");
            return false;
        }

        u8 alertLevel = b.readU8();
        u8 alertID    = b.readU8();

        handleAlert(alertLevel, alertID);

        serverSeqNum++;

        return true;
    }

    // handle alert from other
    void handleAlert(u8 alertLevel, u8 alertID)
    {
        if(alertID == TLS:ALERT_NO_ERROR)
        {
            // ignore
            //logInfo("TLS ALERT_NO_ERROR");
        }
        if(alertID == TLS:ALERT_CLOSE_NOTIFY)
        {
            // closing connection normally
            logError("TLS ALERT_CLOSE_NOTIFY");
            socket.disconnect();
        }
        else
        {
            // error
            logError("TLS ALERT: " + TLS:getAlertStr(alertID));
            socket.disconnect();
        }
    }

    // Read and process cipher change record.
    bool readCipherChangeMsg(ByteArray b)
    {
        if(b.getNumBytesLeft() < 1)
        {
            logError("Change cipher msg too small.");
            return false;
        }

        u8 changeTrue = b.readU8();

        if(this.state != STATE_SENT_VERIFY)
        {
            logError("Got out of order change cipher spec msg from server!");
            return false;
        }

        this.state = STATE_ALL_ENCRYPTED;

        serverSeqNum++;

        return true;
    }

    // Read and process app data record.
    bool readAppDataMsg(ByteArray b, u16 msgBodySize)
    {
        if(b.getNumBytesLeft() < msgBodySize)
        {
            logError("App data msg too small.");
            return false;
        }

        if(this.state != STATE_APP_DATA)
        {
            logError("Got TLS:RECORD_TYPE_APP_DATA before state is STATE_APP_DATA!");
            return false;
        }

        // first 16 bytes IV
        u8[16] msgIV;
        for(u64 v=0; v<16; v++)
            msgIV[v] = b.readU8();

        // decrypt rest
        decryptBuffer.clear();
        decryptBuffer.write(b, b.index, msgBodySize - 16);
        decryptRecord(TLS:RECORD_TYPE_APP_DATA, decryptBuffer, msgIV, serverSeqNum, recvAppBuffer);

        serverSeqNum++;

        return true;
    }

    // Read and process verify msg from server (which is encrypted).
    bool readHandshakeVerifyMsg(ByteArray b, u32 msgStartIndex, u16 msgBodySize)
    {
        // this is encrypted (and must be handshake verify msg from server)
        if(b.getNumBytesLeft() < 28)
        {
            logError("Verify msg from server too small.");
            return false;
        }

        // first 16 bytes IV
        u8[16] msgIV;
        for(u64 v=0; v<16; v++)
            msgIV[v] = b.readU8();

        // decrypt rest
        serverSeqNum = 0; // handshake finished is msg=0. (first encrypted msg from server)
        ByteArray verifyRecord();
        decryptBuffer.clear();
        decryptBuffer.write(b, b.index, msgBodySize - 16);
        decryptRecord(TLS:RECORD_TYPE_HANDSHAKE, decryptBuffer, msgIV, serverSeqNum, verifyRecord);
        verifyRecord.index = 0;

        // another header, 4 bytes total
        u8  handshakeHeaderID = verifyRecord.readU8();
        u32 handshakeBodySize = (u32(verifyRecord.readU8()) << 16) | (u32(verifyRecord.readU8()) << 8) | (u32(verifyRecord.readU8()));

        if(handshakeHeaderID != TLS:HANDSHAKE_FINISHED)
        {
            logError("handshakeHeaderID != TLS:HANDSHAKE_FINISHED");
            return false;
        }

        u8[] verifyFromServer(12);
        for(u64 x=0; x<12; x++)
            verifyFromServer[x] = verifyRecord.readU8();

        // calculate our verify
        u8[] msg(Chars:s, Chars:e, Chars:r, Chars:v, Chars:e, Chars:r, Chars:SPACE, Chars:f, Chars:i, Chars:n, Chars:i, Chars:s, Chars:h, Chars:e, Chars:d); // "server finished"
        u8[32] handshakeMsgsHash = Hashing:hashSHA256(this.handshakeMsgs);
        u8[] seed(msg.length() + 32);
        for(u64 m=0; m<msg.length(); m++)
            seed[m] = msg[m];
        for(u64 q=0; q<32; q++)
            seed[msg.length() + q] = handshakeMsgsHash[q];

        u8[] handHashArray(32);
        for(u64 t=0; t<32; t++)
            handHashArray[t] = handshakeMsgsHash[t];

        // Hashed Message Authentication Cryptography. Returns message digest (based on hashing and xor operations). See RFC 2104.
        u8[] a1 = TLS:hmacArray(masterSecret, seed, seed.length(), Hashing:HASH_SHA256);

        u8[] dataA1Seed(a1.length() + seed.length());
        for(u64 a=0; a<a1.length(); a++)
            dataA1Seed[a] = a1[a];
        for(u64 s=0; s<seed.length(); s++)
            dataA1Seed[a1.length() + s] = seed[s];

        u8[] p1 = TLS:hmacArray(masterSecret, dataA1Seed, dataA1Seed.length(), Hashing:HASH_SHA256);

        u8[] calcVerifyData(12);
        for(u64 p=0; p<12; p++)
            calcVerifyData[p] = p1[p];

        // confirm our calculated verify data matches
        for(u64 c=0; c<12; c++)
        {
            if(calcVerifyData[c] != verifyFromServer[c])
            {
                logError("Verify msg from server does not match our calculated value!");
                return false;
            }
        }

        this.state = STATE_APP_DATA;

        serverSeqNum++;

        // we no longer need these release the memory (and avoid keeping extra secret info)
        //this.serverRandoms   = null;
        //this.clientRandoms   = null;
        //this.preMasterSecret = null;
        //this.masterSecret    = null;

        return true;
    }

    // Read and process hello msg from server.
    bool readHandshakeServerHelloMsg(ByteArray b, u32 msgStartIndex, u16 msgBodySize)
    {
        u64 bIndexVerifyData = b.index - TLS:HANDSHAKE_HEADER_SIZE; // finished message verify_data hash needs data (but not record headers) from handshake msgs

        if(b.getNumBytesLeft() < 2)
        {
            logError("Server hello msg is too small.");
            return false;
        }

        // tls version we agree on
        u8 majorTLSVer = b.readU8();
        u8 minorTLSVer = b.readU8();
        if(minorTLSVer != TLS:VER_1_2)
        {
            logError("Wrong TLS version from server in hello msg. TLS version 1." + String<u8>:formatNumber(minorTLSVer - 1));
            return false;
        }

        // 32 bytes of random data
        if(b.getNumBytesLeft() < 32)
        {
            logError("Server hello msg is too small.");
            return false;
        }

        this.serverRandoms = u8[](32);
        for(u64 c=0; c<32; c++)
            this.serverRandoms[c] = b.readU8();

        if(b.getNumBytesLeft() < 4)
        {
            logError("Server hello msg is too small.");
            return false;
        }

        u8 sessionLen = b.readU8();
        if(sessionLen != 0)
        {
            // read and ignore
            b.index += sessionLen; // we don't support session ids (side channel attacks)
        }

        if(b.getNumBytesLeft() < 3)
            return -11;

        this.cipherMode = b.readU16();

        b.readU8(); // no one uses compression

        // could be extensions
        u32 totalMsgSize = (msgBodySize + TLS:HEADER_SIZE);
        if(b.index < (msgStartIndex + totalMsgSize))
        {
            u16 numAllExtsBytes = b.readU16();
            
            //logInfo("Server hello number of extension bytes: " + String<u8>:formatNumber(numAllExtsBytes));

            // Each extension had a four byte header with an extension ID and u16 number of bytes. The server can only support
            // extensions the client requests.

            b.index = msgStartIndex + totalMsgSize;
        }

        // include extensions msg data (even if we ignore it) for hash 
        this.handshakeMsgs.write(b, bIndexVerifyData, b.index - bIndexVerifyData);

        this.state = STATE_GOT_SERVER_HELLO;

        serverSeqNum++;

        return true;
    }

    // Read and process server certificate msg from server.
    bool readHandshakeServerCertificateMsg(ByteArray b, u32 msgStartIndex, u16 msgBodySize)
    {
        u64 bIndexVerifyData = b.index - TLS:HANDSHAKE_HEADER_SIZE; // finished message verify_data hash needs data (but not record headers) from handshake msgs

        u32 oldIndex = b.index;
        ByteArray msgBytes = b.read(b.numUsed - b.index);
        b.index = oldIndex;

        // length 3 (to support more than 2 byte length...)
        u32 certsNumBytes = (u32(b.readU8()) << 16) | (u32(b.readU8()) << 8) | (u32(b.readU8()));
        u32 startCertBytesIndex = b.index;

        // read certificate chain
        ArrayList<ByteArray> serverCertFiles(); // from server, [0] is server, [n] is top level certificate authority
        while(b.index < (startCertBytesIndex + certsNumBytes))
        {
            // each certificate in DER format (binary) - first 3 bytes define length of certificate
            u32 certNumBytes = (u32(b.readU8()) << 16) | (u32(b.readU8()) << 8) | (u32(b.readU8()));

            if((b.index + certNumBytes) > b.numUsed)
            {
                logError("ERROR: Too few bytes for certificate from server!");
                return false;
            }

            ByteArray certFile = b.read(certNumBytes);
            serverCertFiles.add(certFile);
        }

        // could be extensions, skip over
        u32 totalMsgSize = (msgBodySize + TLS:HEADER_SIZE);
        if(b.index < (msgStartIndex + totalMsgSize))
            b.index = msgStartIndex + totalMsgSize;

        // include extensions msg data (even if we ignore it) for hash
        this.handshakeMsgs.write(b, bIndexVerifyData, b.index - bIndexVerifyData);

        // Parse and validate certificates
        if(validateServerCertChain(serverCertFiles) == false)
            return false; // error messages logged in validateServerCertChain()

        if(serverCerts == null)
        {
            logError("Server certificate msg serverCerts == null!");
            return false;
        }

        if(serverCerts.size() < 1)
        {
            logError("Server certificate msg serverCerts.size() < 1");
            return false;
        }

        rsaPublicKey = RSAPublicKey(serverCerts[0].getRSAPublicKey());

        this.state = STATE_GOT_SERVER_CERTS;

        serverSeqNum++;

        return true;
    }

    // Read and process server handshake hello done msg from server.
    bool readHandshakeServerDoneMsg(ByteArray b, u32 msgStartIndex, u16 msgBodySize)
    {
        u64 bIndexVerifyData = b.index - TLS:HANDSHAKE_HEADER_SIZE; // finished message verify_data hash needs data (but not record headers) from handshake msgs

        // length 2 which is zero for server_done msg (TLS format is ...great)
        b.index += 3;

        // include extensions msg data (even if we ignore it) for hash (via totalMsgSize instead of b.index)
        u32 totalMsgSize = (msgBodySize + TLS:HEADER_SIZE);
        this.handshakeMsgs.write(b, bIndexVerifyData, totalMsgSize - bIndexVerifyData);

        this.preMasterSecret = TLS:generatePremasterSecret();
        this.masterSecret    = TLS:generateMasterSecret(this.clientRandoms, this.serverRandoms, this.preMasterSecret);
        this.keys            = TLS:generateKeysFromMasterSecret(this.cipherMode, this.clientRandoms, this.serverRandoms, this.masterSecret);
        this.clientEncrypter = AES:createCBC(keys.clientKey); // CBC mode
        this.serverDecrypter = AES:createCBC(keys.serverKey); // CBC mode

        u8[16] initVector = TLS:generateIV(); // used for writeClientHandshakeVerifyMsg()

        // send key
        this.writeClientKeyExchangeRSAMsg(sendBuffer, preMasterSecret);
        socket.send(sendBuffer.data, sendBuffer.numUsed);
        sendBuffer.clear();

        // send cipher change message
        this.writeChangeCipherMsg(sendBuffer);
        socket.send(sendBuffer.data, sendBuffer.numUsed);
        sendBuffer.clear();

        // send client handshake finished message
        this.writeClientHandshakeVerifyMsg(sendBuffer, initVector);
        socket.send(sendBuffer.data, sendBuffer.numUsed);
        sendBuffer.clear();

        this.state = STATE_SENT_VERIFY;

        serverSeqNum++;

        return true;
    }

    // Validate server certificate chain from files (includes parsing from DER files).
    bool validateServerCertChain(ArrayList<ByteArray> certFiles)
    {
        if(certFiles == null)
            return false;

        if(certFiles.size() == 0)
            return false;

        // Read certificates
        for(u64 f=0; f<certFiles.size(); f++)
        {
            X509Certificate cert();
            if(cert.readCertificate(certFiles[f]) == false)
            {
                logError("ERROR: Failed to parse (read) certificate from server!");
                return false;
            }

            cert.certFile = certFiles[f];
            serverCerts.add(cert);
        }

        // Validate 
        String<u8> verifyErrorsStr();
        if(TLS:getTrustStore().validateCertChain(serverCerts, verifyErrorsStr) == false)
        {
            logError("ERROR: Failed to verify certificate chain. Reason: " + verifyErrorsStr + "\n");
            return false;
        }

        return true;
    }

    // Client sends hello to server. ciphers = u16[](TLS:CIPHER_RSA_AES128_CBC_SHA256, TLS:CIPHER_RSA_AES256_CBC_SHA256) etc.
    void writeClientHelloMsg(ByteArray b, u8 tlsVersionWanted, u16[] ciphers)
    {
        // header
        b.writeU8(TLS:RECORD_TYPE_HANDSHAKE); // record ID
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(TLS:VER_1_2); // version "minor" - minimum we support is 1.2, but some 1.2 servers fail is client isn't 1.0 to start (?!) others fail if this isn't 1.2 (the correct version).
        u64 lenIndex = b.index;
        b.writeU8(0); // record length in bytes (high bits of u16)
        b.writeU8(0); // record length in bytes (low bits of u16)

        u64 bIndexVerifyData = b.index; // finished message verify_data hash needs data (but not record headers) from handshake msgs

        // handshake header is id (1 byte) + length of data to follow (3 bytes)
        b.writeU8(TLS:HANDSHAKE_CLIENT_HELLO);

        // length 2 (because...reasons)
        u64 len2Index = b.index;
        b.writeU8(0);
        b.writeU8(0);
        b.writeU8(0);

        // certificates (all) length that follow

        // TLS version we want to agree on
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(tlsVersionWanted); // version "minor"

        // 32 true random bytes - no longer recommended to use first 4 bytes as GMT/UTC time
        this.clientRandoms = TLS:generateTrueRandomBytes(32);
        for(u64 r=0; r<this.clientRandoms.length(); r++)
            b.writeU8(this.clientRandoms[r]);

        // session id length bytes (if zero, no id bytes written)
        b.writeU8(0);

        // ciphers
        b.writeU8(0); // length
        b.writeU8(ciphers.length() * 2); // length
        for(u64 c=0; c<ciphers.length(); c++)
        {
            b.writeU16(ciphers[c]);
        }

        // compression methods (no one uses)
        b.writeU8(1); // length u16
        b.writeU8(0); // compression id (none)

        // no extensions supported, so no extra bytes

        // update length (excludes header)
        u16 msgBodyLen = b.index - (lenIndex + 2); // + 2 because length bytes not included
        b.writeU8(lenIndex + 0, (msgBodyLen & 0xFF00) >> 8); // high byte
        b.writeU8(lenIndex + 1, (msgBodyLen & 0x00FF)); // low byte

        // update length 2 (excludes header and handshake header - yes two headers)
        u16 msgBody2Len = b.index - (len2Index + 3); // + 3 because 3-byte length not included
        b.writeU8(len2Index + 0, 0); // assume high byte is 0
        b.writeU8(len2Index + 1, (msgBody2Len & 0xFF00) >> 8); // high byte
        b.writeU8(len2Index + 2, (msgBody2Len & 0x00FF)); // low byte

        this.handshakeMsgs.write(b, bIndexVerifyData, b.numUsed - bIndexVerifyData);
        clientSeqNum++;
    }

    // Client sends key parameters. preMasterSecret is 48 bytes always with the first two bytes being the protocol version (TLS 1.2 = "3, 3").
    void writeClientKeyExchangeRSAMsg(ByteArray b, u8[] preMasterSecret48Bytes)
    {
        // header
        b.writeU8(TLS:RECORD_TYPE_HANDSHAKE); // record ID
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(tlsVer); // version "minor"
        u64 lenIndex = b.index;
        b.writeU8(0); // record length in bytes (high bits of u16)
        b.writeU8(2); // record length in bytes (low bits of u16)

        u64 bIndexVerifyData = b.index; // finished message verify_data hash needs data (but not record headers) from handshake msgs

        // handshake header is id (1 byte) + length of data to follow (3 bytes)
        b.writeU8(TLS:HANDSHAKE_CLIENT_KEY_EXCHANGE);

        // length 2 (because...reasons)
        u64 len2Index = b.index;
        b.writeU8(0);
        b.writeU8(0);
        b.writeU8(0);

        // key parameters - preMasterSecret
        u8[] encryptedPMS = rsaPublicKey.encryptPKCS1(preMasterSecret48Bytes);

        b.writeU16(encryptedPMS.length()); // "network byte order" (AKA big endian) here
        b.write(encryptedPMS);

        // no extensions supported, so no extra bytes

        // update length (excludes header)
        u16 msgBodyLen = b.index - (lenIndex + 2); // + 2 because length bytes not included
        b.writeU8(lenIndex + 0, (msgBodyLen & 0xFF00) >> 8); // high byte
        b.writeU8(lenIndex + 1, (msgBodyLen & 0x00FF)); // low byte

        // update length 2 (excludes header and handshake header - yes two headers)
        u16 msgBody2Len = b.index - (len2Index + 3); // + 3 because 3-byte length not included
        b.writeU8(len2Index + 0, 0); // assume high byte is 0
        b.writeU8(len2Index + 1, (msgBody2Len & 0xFF00) >> 8); // high byte
        b.writeU8(len2Index + 2, (msgBody2Len & 0x00FF)); // low byte

        this.handshakeMsgs.write(b, bIndexVerifyData, b.numUsed - bIndexVerifyData);
        clientSeqNum++;
    }

    // Client sends key parameters if needed.
    // Client can't provide signature (unless using client certificates etc.).
    // Example: For ECDHE curveID=0x001d is curve x25519.
    void writeClientKeyExchangeECDHEMsg(ByteArray b, u16 curveID, u8[] ephemeralPublicKey)
    {
        // header
        b.writeU8(TLS:RECORD_TYPE_HANDSHAKE); // record ID
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(tlsVer); // version "minor"
        u64 lenIndex = b.index;
        b.writeU8(0); // record length in bytes (high bits of u16)
        b.writeU8(2); // record length in bytes (low bits of u16)

        u64 bIndexVerifyData = b.index; // finished message verify_data hash needs data (but not record headers) from handshake msgs

        // handshake header is id (1 byte) + length of data to follow (3 bytes)
        b.writeU8(TLS:HANDSHAKE_CLIENT_KEY_EXCHANGE);

        // length 2 (because...reasons)
        u64 len2Index = b.index;
        b.writeU8(0);
        b.writeU8(0);
        b.writeU8(0);

        // key parameters

        // named curve
        b.writeU8(0x03);
        b.writeU8((curveID & 0xFF00) >> 8);
        b.writeU8(curveID & 0x00FF);

        // public key
        b.writeU8(ephemeralPublicKey.length());
        b.write(ephemeralPublicKey);

        // no extensions supported, so no extra bytes

        // update length (excludes header)
        u16 msgBodyLen = b.index - (lenIndex + 2); // + 2 because length bytes not included
        b.writeU8(lenIndex + 0, (msgBodyLen & 0xFF00) >> 8); // high byte
        b.writeU8(lenIndex + 1, (msgBodyLen & 0x00FF)); // low byte

        // update length 2 (excludes header and handshake header - yes two headers)
        u16 msgBody2Len = b.index - (len2Index + 3); // + 3 because 3-byte length not included
        b.writeU8(len2Index + 0, 0); // assume high byte is 0
        b.writeU8(len2Index + 1, (msgBody2Len & 0xFF00) >> 8); // high byte
        b.writeU8(len2Index + 2, (msgBody2Len & 0x00FF)); // low byte

        this.handshakeMsgs.write(b, bIndexVerifyData, b.numUsed - bIndexVerifyData);
        clientSeqNum++;
    }

    // Client sends verification (encrypted/MAC) data using emphereal keys.
    void writeClientHandshakeVerifyMsg(ByteArray b, u8[16] initVec)
    {
        // header
        b.writeU8(TLS:RECORD_TYPE_HANDSHAKE); // record ID
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(tlsVer); // version "minor"
        u64 lenIndex = b.index;
        b.writeU8(0); // record length in bytes (high bits of u16)
        b.writeU8(2); // record length in bytes (low bits of u16)

        u64 bIndexVerifyData = b.index; // finished message verify_data hash needs data (but not record headers) from handshake msgs

        // 16 byte initialization vector comes before header
        for(u64 v=0; v<16; v++)
            b.writeU8(initVec[v]);

        // the rest is encrypted
        encryptBuffer.clear();

        // handshake header is id (1 byte) + length of data to follow (3 bytes)
        encryptBuffer.writeU8(TLS:HANDSHAKE_FINISHED);

        // length 2
        u64 len2Index = encryptBuffer.index;
        encryptBuffer.writeU8(0);
        encryptBuffer.writeU8(0);
        encryptBuffer.writeU8(12);

        // Verify Data
        // The verify_data is built from the master secret and the hash of the payload of all handshake records (type=0x16) previous to this one. 
        // The calculation for verify_data is as follows:
        // 
        // seed = "client finished" + SHA256(all handshake messages)
        // a0 = seed
        // a1 = HMAC-SHA256(key=MasterSecret, data=a0)
        // p1 = HMAC-SHA256(key=MasterSecret, data=a1 + seed)
        // verify_data = p1[first 12 bytes]

        //
        //handshake_messages
        // All of the data from all messages in this handshake (not
        // including any HelloRequest messages) up to, but not including,
        // this message.  This is only data visible at the handshake layer
        // and does not include record layer headers.  This is the
        // concatenation of all the Handshake structures as defined in
        // Section 7.4, exchanged thus far.

        u8[] msg(Chars:c, Chars:l, Chars:i, Chars:e, Chars:n, Chars:t, Chars:SPACE, Chars:f, Chars:i, Chars:n, Chars:i, Chars:s, Chars:h, Chars:e, Chars:d); // "client finished"
        u8[32] handshakeMsgsHash = Hashing:hashSHA256(this.handshakeMsgs);
        u8[] seed(msg.length() + 32);
        for(u64 m=0; m<msg.length(); m++)
            seed[m] = msg[m];
        for(u64 q=0; q<32; q++)
            seed[msg.length() + q] = handshakeMsgsHash[q];

        u8[] handHashArray(32);
        for(u64 t=0; t<32; t++)
            handHashArray[t] = handshakeMsgsHash[t];

        // Hashed Message Authentication Cryptography. Returns message digest (based on hashing and xor operations). See RFC 2104.
        u8[] a1 = TLS:hmacArray(masterSecret, seed, seed.length(), Hashing:HASH_SHA256);

        u8[] dataA1Seed(a1.length() + seed.length());
        for(u64 a=0; a<a1.length(); a++)
            dataA1Seed[a] = a1[a];
        for(u64 s=0; s<seed.length(); s++)
            dataA1Seed[a1.length() + s] = seed[s];

        u8[] p1 = TLS:hmacArray(masterSecret, dataA1Seed, dataA1Seed.length(), Hashing:HASH_SHA256);

        u8[] verifyData(12);
        for(u64 p=0; p<12; p++)
            verifyData[p] = p1[p];
        
        // write verify data
        for(u64 v=0; v<verifyData.length(); v++)
            encryptBuffer.writeU8(verifyData[v]);

        // update handshake data for use by server verification msg (not this client->server msg)
        this.handshakeMsgs.write(encryptBuffer, 0, encryptBuffer.numUsed);

        // encrypt encryptBuffer and append encrypted bytes to b buffer
        clientSeqNum = 0; // first message encrypted is SeqNum=0
        this.encryptRecord(encryptBuffer, initVec, clientSeqNum, TLS:RECORD_TYPE_HANDSHAKE, 16); // record size should be entire payload (handshake record header included)

        // write encrypted data
        for(u64 v=0; v<encryptBuffer.size(); v++)
            b.writeU8(encryptBuffer[v]);

        // no extensions supported, so no extra bytes

        // update length (excludes header)
        u16 msgBodyLen = b.index - (lenIndex + 2); // + 2 because length bytes not included
        b.writeU8(lenIndex + 0, (msgBodyLen & 0xFF00) >> 8); // high byte
        b.writeU8(lenIndex + 1, (msgBodyLen & 0x00FF)); // low byte
        
        clientSeqNum++;
    }

    // Client/Server sends alert message. level is 1 or 2
    void writeAlertMsg(ByteArray b, u8 level, u8 alertID)
    {
        // header
        b.writeU8(TLS:RECORD_TYPE_ALERT); // record ID
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(tlsVer); // version "minor"
        b.writeU8(0); // record length in bytes (high bits of u16)
        b.writeU8(2); // record length in bytes (low bits of u16)

        // alert body
        b.writeU8(level);
        b.writeU8(alertID);
        clientSeqNum++;
    }

    // Server sends change cipher spec message.
    void writeChangeCipherMsg(ByteArray b)
    {
        // header
        b.writeU8(TLS:RECORD_TYPE_CHANGE_CIPHER); // record ID
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(tlsVer); // version "minor"
        b.writeU8(0); // record length in bytes (high bits of u16)
        b.writeU8(1); // record length in bytes (low bits of u16)

        // change body
        b.writeU8(1); // "true"
        clientSeqNum++;
    }

    // Server or client sends app data message.
    void writeAppDataMsg(ByteArray b, u8[16] iv, u8[] data, u64 index, u16 numBytes)
    {
        // header
        b.writeU8(TLS:RECORD_TYPE_APP_DATA); // record ID
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(tlsVer); // version "minor"
        u64 lenIndex = b.index;
        b.writeU8((numBytes & 0xFF00) >> 8); // record length in bytes (high bits of u16)
        b.writeU8((numBytes & 0x00FF)); // record length in bytes (low bits of u16)

        // IV (kinda part of header)
        for(u64 v=0; v<16; v++)
            b.writeU8(iv[v]);

        // after IV everything encrypted
        this.encryptBuffer.clear();
        this.encryptBuffer.write(data, index, numBytes);
        this.encryptRecord(this.encryptBuffer, iv, clientSeqNum, TLS:RECORD_TYPE_APP_DATA, encryptBuffer.size());

        // write encrypted data
        for(u64 v=0; v<encryptBuffer.size(); v++)
            b.writeU8(encryptBuffer[v]);

        // update length (excludes header)
        u16 msgBodyLen = b.index - (lenIndex + 2); // + 2 because length bytes not included
        b.writeU8(lenIndex + 0, (msgBodyLen & 0xFF00) >> 8); // high byte
        b.writeU8(lenIndex + 1, (msgBodyLen & 0x00FF)); // low byte

        clientSeqNum++;
    }

    // Encrypt data record, appending MAC and padding before encrypting.
    void encryptRecord(ByteArray data, u8[16] iv, u64 sequenceNumber, u8 recordType, u32 recordLength)
    {
        u64 MAC_LEN = 20;
        u64 PAD_TO  = 16;

        data.index = data.numUsed;

        u8[64] macBuf = TLS:calcMsgMAC(TLS:getHashFuncType(this.cipherMode), keys.clientKeyMAC, sequenceNumber, recordType, recordLength, data);
        for(u64 i=0; i<MAC_LEN; i++)
            data.writeU8(macBuf[i]); // append msg code

        // So TLS 1.2 uses PKCS7 padding, but also there is a single byte length of padding 
        // field at the end of the data (after MAC). Why? An attempt at backwards compatibility
        // with SSLv2/3.
        u64 numPadBytes = PAD_TO - ((data.size()+1) % PAD_TO);
        if(numPadBytes == 0)
            numPadBytes = PAD_TO; // one whole block of padding
        data.writeU8(numPadBytes); // this will be the same value as what PKCS7 writes out
        PKCS7:pad(data, PAD_TO);

        clientEncrypter.setIV(iv); // each message choose an IV
        clientEncrypter.encrypt(data.data, data.size());
    }

    // Decrypt data record, verifying MAC. Returns null if failed (MAC failure etc.).
    void decryptRecord(u8 recordType, ByteArray data, u8[16] iv, u64 sequenceNumber, ByteArray outData)
    {
        u64 MAC_LEN = 20;
        u64 PAD_TO  = 16;

        if(data == null)
        {
            logError("TLSClient.decryptRecord() data=null");
            return;
        }

        if(data.size() == 0)
        {
            logError("TLSClient.decryptRecord() data.size() = 0"); // Forbidden in TLS
            return;
        }

        if((data.size() % PAD_TO) != 0)
        {
            logError("TLSClient.decryptRecord() (data.size() % PAD_TO) != 0"); // Since we only support AES 128/256 which have block sizes of 16
            return;
        }

        serverDecrypter.setIV(iv); // each message choose an IV
        serverDecrypter.decrypt(data.data, data.numUsed);

        PKCS7:unpad(data, PAD_TO);
        if(data.size() == 0)
        {
            logError("TLSClient.decryptRecord() bad padding");
            return;
        }

        // minimum record size is MAC
        if(data.size() < MAC_LEN)
        {
            logError("TLSClient.decryptRecord() unpaddedData too small (MAC minimum)");
            return;
        }

        u8[64] recordMAC;
        for(u64 m=0; m<MAC_LEN; m++)
            recordMAC[m] = data[(data.size() - 21) + m]; // -21 because last byte isn't part of HMAC it's just a byte specifying padding (outside of PKCS7)

        outData.write(data, 0, data.size() - 21);
        u32 recordLength = outData.size(); // -1 because of last byte indicating padding (but not part of PKCS7) // (u32(unpaddedData[1]) << 16) | (u32(unpaddedData[2]) << 8) | (u32(unpaddedData[3]));

        // MAC must be last 20 bytes
        u8[64] checkMAC = TLS:calcMsgMAC(TLS:getHashFuncType(this.cipherMode), keys.serverKeyMAC, sequenceNumber, recordType, recordLength, outData);

        bool badMAC = false;
        for(u64 m=0; m<MAC_LEN; m++)
        {
            if(recordMAC[m] != checkMAC[m])
                badMAC = true;
        }

        if(badMAC == true)
        {
            logError("TLSClient.decryptRecord() checkMAC != recordMAC, bad MAC.");
            return;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// TLSServer
////////////////////////////////////////////////////////////////////////////////////////////////////

// Manages the server side of the TLS connection. Wraps TCP socket. Supports TLS 1.2 only. 
// Implements ISocket interface so it can be used as a drop-in replacement for normal socket
// operations. Each TLSServer uses a few hundred KB of memory (minimum).
class TLSServer implements ISocket
{
    // State of client connection
    const u8 STATE_WAITING_FOR_CLIENT_HELLO = 0;   // Waiting for client hello msg
    const u8 STATE_SERVER_HELLO_DONE_SENT   = 1;   // Server sent hello, certs, and hello_done msgs
    const u8 STATE_GOT_CLIENT_KEYS          = 2;   // We got client RSA key exchange
    const u8 STATE_GOT_CLIENT_CHANGE_CIPHER = 3;   // We got client cipher change, waiting for client verify msg
    const u8 STATE_APP_DATA                 = 4;   // We got client verify msg and sent server verify msg, everything is setup now
    const u8 STATE_WAIT_TO_DISCONNECT       = 100; // If the server provides bad handshake, bad MAC etc. we always kill the connection at the same time to mitigate timing attacks
    const u8 STATE_DISCONNECT_CLIENT        = 253; // Disconnect by client
    const u8 STATE_DISCONNECT_SERVER        = 254; // Disconnect by server
    const u8 STATE_ERROR                    = 255; // Fatal error

    const f64 DISCONNECT_WAIT_TIME = 5000.0; // N milliseconds from the last message receieved (if error triggered)

    TCPSocket socket; // to client
    u16[] allowedCiphers = null; // allowed ciphers to be ordered from least secure to most secure (or most preferred)
    u8   tlsVer       = TLS:VER_1_2;     // version we agree to use, must be 1.2
    u16  cipherMode   = TLS:CIPHER_NULL; // agreed upon cipher suite to use for connection
    u8   state        = 0; // one of STATE_CONNECTING etc.
    u64  clientSeqNum = 0; // Each TLS record sent by the client causes this to increment 1. Used in MAC.
    u64  serverSeqNum = 0; // Each TLS record sent by the server causes this to increment 1. Used in MAC.
    u8[] serverRandoms;    // 28 bytes, or 32 including time at start
    u8[] clientRandoms;    // 28 bytes, or 32 including time at start
    u8[] preMasterSecret;  // 48 bytes for RSA
    u8[] masterSecret;     // 48 bytes for all key exchange methods
    TLSKeys keys;          // final connection keys
    AES clientDecrypter;   // could be CBC or CTR mode.
    AES serverEncrypter;   // could be CBC or CTR mode.
    ArrayList<ByteArray> serverCertFiles; // certificates in DER binary form to be put in server certs msg where server end-entity cert is first (zero index).
    X509Certificate      serverCert;      // public certificate for server
    RSAPublicKey         rsaPublicKey;    // server
    RSAKey               rsaPrivateKey;   // corresponding to public key
    ByteArray serverCertsBinary(); // certificate chain, ready to be written to msg
    ByteArray handshakeMsgs(1024); // for verification data calculation
    f64 disconnectTime; // when we should disconnect
    ByteArray sendBuffer(TLS:MIN_BUFFER_SIZE); // For raw TCP socket send.
    ByteArray recvBuffer(TLS:MIN_BUFFER_SIZE); // For raw TCP socket recv.
    ByteArray encryptBuffer(TLS:MIN_BUFFER_SIZE); // Intermediate buffer for encrypting
    ByteArray decryptBuffer(TLS:MIN_BUFFER_SIZE); // Intermediate buffer for decrypting
    ByteArray sendAppBuffer(TLS:MIN_BUFFER_SIZE); // Application data send (decrypted). This is the only data users of TLSServer send.
    ByteArray recvAppBuffer(TLS:MIN_BUFFER_SIZE); // Application data recv (decrypted). This is the only data users of TLSServer recv.
    bool debugLogging = true; // debugging, if true, logs connection info

    // Create client wrapping TCP ssocket. allowedCiphers=null will use default ones. serverCertFiles must be in-order with server end-entity cert first.
    void constructor(TCPSocket socket, u16[] allowedCiphers, RSAKey privateKey, X509Certificate serverCert, ArrayList<ByteArray> serverCertFiles)
    {
        this.socket = socket;
        this.state  = STATE_WAITING_FOR_CLIENT_HELLO;

        this.sendBuffer.setBigEndian(); // network byte order for TLS
        this.recvBuffer.setBigEndian(); // network byte order for TLS

        if(allowedCiphers == null)
            this.allowedCiphers = TLS:getDefaultCiphers();
        else
            this.allowedCiphers = allowedCiphers.clone();

        this.disconnectTime = System:getTime() + DISCONNECT_WAIT_TIME;

        this.rsaPrivateKey   = RSAKey(privateKey);
        this.rsaPublicKey    = privateKey.getPublicKey();
        this.serverCert      = X509Certificate(serverCert);
        this.serverCertFiles = serverCertFiles.clone();
    }

    // [ISocket] Get address we are bound to (local machine). Applies for all sockets.
	IPAddress getSourceIP();

	// [ISocket] Get address we are connected to. Does not apply for TCP listen() sockets.
	IPAddress getDestinationIP();

	// [ISocket] Connecting, Disconnected etc. See SocketState for values.
	u8 getState()
    {
        if(socket == null)
            return 0;

        return socket.getState();
    }

	// [ISocket] Send data via socket.
	bool send(u8[] data, u32 numBytes)
    {
        return sendAppData(data, 0, numBytes);
    }

	// [ISocket] Send data via socket.
	bool send(u8[] data, u32 dataStartIndex, u32 numBytes)
    {
        return sendAppData(data, dataStartIndex, numBytes);
    }

	// [ISocket] Send data via socket. toIP parameter applies to UDP only, ignored by TCP.
	bool send(u8[] data, u32 numBytes, IPAddress toIP)
    {
        return sendAppData(data, 0, numBytes);
    }

	// [ISocket] Send data via socket. toIP parameter applies to UDP only, ignored by TCP.
	bool send(u8[] data, u32 dataStartIndex, u32 numBytes, IPAddress toIP)
    {
        return sendAppData(data, dataStartIndex, numBytes);
    }

	// [ISocket] Receive data from socket into data.
	u32 receive(u8[] data)
    {
        return receive(data, 0);
    }

	// [ISocket] Receive data from socket.
	u32 receive(u8[] data, u32 dataStartIndex)
    {
        update();

        if(recvAppBuffer == null)
            return 0;

        if(recvAppBuffer.size() == 0)
            return 0;

        if(dataStartIndex >= data.length())
            return 0;

        u64 numBytes = Math:min(recvAppBuffer.size(), data.length() - dataStartIndex);

        for(u64 b=0; b<numBytes; b++)
        {
            data[dataStartIndex + b] = recvAppBuffer.data[b];
        }

        recvAppBuffer.remove(0, numBytes);

        return numBytes;
    }

	// [ISocket] Receive data from socket. outIP parameter applies to UDP only, ignored by TCP.
	u32 receive(u8[] data, IPAddress outIP)
    {
        return receive(data, 0);
    }

	// [ISocket] Receive data from socket. outIP parameter applies to UDP only, ignored by TCP.
	u32 receive(u8[] data, u32 dataStartIndex, IPAddress outIP)
    {
        return receive(data, dataStartIndex);
    }

    // Get buffer containing recv'd application data.
    ByteArray getAppRecvBuffer()
    {
        return recvAppBuffer;
    }

    // Send application data. Will be buffered until TLS connection established.
    bool sendAppData(u8[] appData, u64 index, u64 numBytes)
    {
        this.sendAppBuffer.write(appData, index, numBytes);
        update(); // will cause data to be sent right away if possible
        return true;
    }

	// [ISocket] Disconnect socket from destination.
	void disconnect()
    {
        if(socket == null)
            return;

        socket.disconnect();
        socket = null;

        this.state = STATE_DISCONNECT_CLIENT;
    }

    // State ID, one of STATE_
    u8 getTLSState()
    {
        return this.state;
    }

    // State String, one of STATE_
    String<u8> getTLSStateName()
    {
        if(this.state == STATE_WAITING_FOR_CLIENT_HELLO)
            return "STATE_WAITING_FOR_CLIENT_HELLO";
        else if(this.state == STATE_SERVER_HELLO_DONE_SENT)
            return "STATE_SERVER_HELLO_DONE_SENT";
        else if(this.state == STATE_GOT_CLIENT_KEYS)
            return "STATE_GOT_CLIENT_KEYS";
        else if(this.state == STATE_GOT_CLIENT_CHANGE_CIPHER)
            return "STATE_GOT_CLIENT_CHANGE_CIPHER";
        else if(this.state == STATE_APP_DATA)
            return "STATE_APP_DATA";
        else if(this.state == STATE_WAIT_TO_DISCONNECT)
            return "STATE_WAIT_TO_DISCONNECT";
        else if(this.state == STATE_DISCONNECT_CLIENT)
            return "STATE_DISCONNECT_CLIENT";
        else if(this.state == STATE_DISCONNECT_SERVER)
            return "STATE_DISCONNECT_SERVER";
        else if(this.state == STATE_ERROR)
            return "STATE_ERROR";

        return "STATE_UNKNOWN";
    }

    // Internal logging 
    void logInfo(String<u8> msg)
    {
        if(debugLogging == false)
            return;

        Log:log(msg + "\n");
    }

    // Internal logging 
    void logError(String<u8> msg)
    {
        this.state = STATE_WAIT_TO_DISCONNECT;

        if(debugLogging == false)
            return;

        Log:log(msg + "\n");
    }

    // Update. Poll reguarly to process messages etc.
    void update()
    {
        if(this.state == STATE_ERROR || this.state == STATE_DISCONNECT_CLIENT || this.state == STATE_DISCONNECT_SERVER)
            return;

        if(this.state == STATE_WAIT_TO_DISCONNECT)
        {
            // just waiting
            if(this.disconnectTime < System:getTime())
            {
                logError("TLSServer Disconnected due to bad handshake/MAC.");

                this.state = STATE_ERROR; // we disconnected because of bad handshake or bad record MAC etc.
                if(socket != null)
                {
                    socket.disconnect();
                    socket = null;
                }
            }

            return;
        }

        // check TCP socket state first
        if(socket == null)
            return;

        if(socket.getState() == SocketState:CONNECTING)
        {
			return; // wait...
        }

        if(socket.getState() != SocketState:CONNECTED)
            return; // disconnected etc.

        // Recv any waiting data, process incomming messages
        updateRecv();

        // Update TLS connection state
        updateTLSState();
    }

    // Read data from TCP socket
    void updateRecv()
    {
        // receive data
        u32 numRecv = socket.receive(recvBuffer.data, recvBuffer.numUsed);
        recvBuffer.numUsed += numRecv;

        // check for complete message to process
        recvBuffer.index = 0;
        i32 numRead = readMsg(recvBuffer);
        if(numRead < 0)
        {
            logError("ERROR: Error reading message from server! Code: " + String<u8>:formatNumber(numRead));

            // error, close connection
            socket.disconnect();
            socket = null;
            return;
        }
        else if(numRead > 0)
        {
            recvBuffer.remove(0, numRead); // remove bytes of processed message
            recvBuffer.index = 0; // back to start
        }
        // else if(numRead == 0) // this is fine, just waiting for more data (partial message bytes)
    }

    // Update TLS connection state (as opposed to TCP)
    void updateTLSState()
    {
        // The process for connecting from server to client (RSA) is:
        // 1. TCP connection from server to client
        // 2. Client sends client hello msg to server
        // 3. Server responds with server hello msg
        // 4. Server sends certificate(s)
        // 5. Client responds with verify message
        // 6. Server responds with it's verify message
        // 7. Then in app data state

        if(this.state == STATE_WAITING_FOR_CLIENT_HELLO)
        {
            // just wait
        }
        else if(this.state == STATE_SERVER_HELLO_DONE_SENT)
        {
            // waiting for client keys
        }
        else if(this.state == STATE_GOT_CLIENT_KEYS)
        {
            // waiting for client change cipher msg
        }
        else if(this.state == STATE_GOT_CLIENT_CHANGE_CIPHER)
        {
            // waiting for client verify msg
        }
        else if(this.state == STATE_APP_DATA)
        {
            // check if we need to send app data
            while(sendAppBuffer.size() > 0)
            {
                u16 MAX_APP_BYTES = 1024; // Considering MTU and such, smaller packets are better for latency / avoiding fragmentation, also TLS msg has max 16 KB size.

                u16 numBytesToSend = MAX_APP_BYTES; 
                if(sendAppBuffer.size() < MAX_APP_BYTES)
                    numBytesToSend = sendAppBuffer.size();

                // encrypt and send
                this.writeAppDataMsg(sendBuffer, TLS:generateIV(), sendAppBuffer.data, 0, numBytesToSend);
                socket.send(sendBuffer.data, sendBuffer.numUsed);
                sendBuffer.clear();

                if(sendAppBuffer.size() < MAX_APP_BYTES)
                    sendAppBuffer.clear();
                else
                    sendAppBuffer.remove(0, MAX_APP_BYTES); // just remove first N bytes
            }
        }
    }

    // Read/parse msg. Returns 0 if not enough data in b yet (partial message). Returns -ve for error. Postive number is number of bytes in next message read.
    i32 readMsg(ByteArray b)
    {
        // TLS Packet:
        //
        // HEADER:
        // Byte 0: TLS Record Type
        // Byte 1-2: TLS VERSION (major, minor)
        // Byte 3-4: Length of data in the record, excluding implied header (16 KB max)
        //
        // RECORD: (varies)

        if(b == null)
            return -1;

        // record header minimum 5 bytes
        if(b.getNumBytesLeft() < 5)
            return 0;

        u32 msgStartIndex = b.index;

        u8 msgID        = b.readU8(); // TLS:RECORD_TYPE_HANDSHAKE etc.
        u8 majorVersion = b.readU8();
        u8 minorVersion = b.readU8();

        //logInfo("TLSServer.readMsg() msg: " + TLS:getRecordName(msgID));

        // Some clients will send messages (like alerts) as TLS 1.0 (3, 1). TLS real-world implementation is a fucking mess.
        //if(minorVersion != TLS:VER_1_2)
        //    return -2;

        u16 msgBodySize = u16(b.readU8()) << 8; // doesn't include header bytes (5)
        msgBodySize |= b.readU8();

        u32 totalMsgSize = (msgBodySize + TLS:HEADER_SIZE);
        if(totalMsgSize > b.numUsed)
        {
            b.index -= TLS:HEADER_SIZE; // go back
            return 0;
        }

        // IMPORTANT MITIGATION: We use a constant time offset to disconnect when entering an error state caused by a
        // bad msg from client. This is designed to thwart "timing" attacks because every bad record MAC or padding 
        // error sees exactly the same response from us.
        this.disconnectTime = System:getTime() + DISCONNECT_WAIT_TIME;

        // different record types
        if(msgID == TLS:RECORD_TYPE_ALERT)
        {   
            if(readAlertMsg(b) == false)
                return -1;
        }
        else if(msgID == TLS:RECORD_TYPE_CHANGE_CIPHER)
        {
            if(readCipherChangeMsg(b) == false)
                return -1;

            this.state = STATE_GOT_CLIENT_CHANGE_CIPHER;
        }
        else if(msgID == TLS:RECORD_TYPE_APP_DATA)
        {
            if(readAppDataMsg(b, msgBodySize) == false)
                return -1;
        }
        else if(msgID == TLS:RECORD_TYPE_HANDSHAKE) // this is ~10 msg types
        {
            if(b.getNumBytesLeft() < 4)
                return -1;

            if(this.state == STATE_WAITING_FOR_CLIENT_HELLO)
            {
                // another header, 4 bytes total
                u8  handshakeHeaderID = b.readU8();
                u32 handshakeBodySize = (u32(b.readU8()) << 16) | (u32(b.readU8()) << 8) | (u32(b.readU8()));
                
                if(handshakeHeaderID != TLS:HANDSHAKE_CLIENT_HELLO)
                {
                    logError("handshakeHeaderID != TLS:HANDSHAKE_CLIENT_HELLO");
                    return -1;
                }

                // has to be client hello, otherwise error
                if(readClientHelloMsg(b, msgStartIndex, msgBodySize) == false)
                    return -1;

                // send server hello in response
                this.writeServerHelloMsg(sendBuffer);
                socket.send(sendBuffer.data, sendBuffer.numUsed);
                sendBuffer.clear();

                // send server certificate chain too
                this.writeServerCertsMsg(sendBuffer);
                socket.send(sendBuffer.data, sendBuffer.numUsed);
                sendBuffer.clear();

                // write server handshake done msg
                this.writeHandshakeServerHelloDoneMsg(sendBuffer);
                socket.send(sendBuffer.data, sendBuffer.numUsed);
                sendBuffer.clear();

                this.state = STATE_SERVER_HELLO_DONE_SENT;
            }
            else if(this.state == STATE_SERVER_HELLO_DONE_SENT)
            {
                // another header, 4 bytes total
                u8  handshakeHeaderID = b.readU8();
                u32 handshakeBodySize = (u32(b.readU8()) << 16) | (u32(b.readU8()) << 8) | (u32(b.readU8()));

                if(handshakeHeaderID != TLS:HANDSHAKE_CLIENT_KEY_EXCHANGE)
                {
                    logError("handshakeHeaderID != TLS:HANDSHAKE_CLIENT_KEY_EXCHANGE");
                    return -1;
                }

                // has to be client keys msg
                if(readClientKeyExchangeRSAMsg(b, msgStartIndex, msgBodySize) == false)
                    return -1;

                this.state = STATE_GOT_CLIENT_KEYS;
            }
            else if(this.state == STATE_GOT_CLIENT_CHANGE_CIPHER)
            {
                // has to be client verify msg
                if(readClientHandshakeVerifyMsg(b, msgStartIndex, msgBodySize) == false)
                    return -1;

                // send server cipher change message
                this.writeChangeCipherMsg(sendBuffer);
                socket.send(sendBuffer.data, sendBuffer.numUsed);
                sendBuffer.clear();

                // send server verify msg
                this.writeServerHandshakeVerifyMsg(sendBuffer);
                socket.send(sendBuffer.data, sendBuffer.numUsed);
                sendBuffer.clear();

                // done handshake both sides, onto app data transfer
                this.state = STATE_APP_DATA;
            }
            else
            {
                logError("Got unknown handshake msg from server!");
                return -1;
            }
        }
        else
        {
            logError("Got unknown msg from server!");

            return -1; // don't know this message type
        }

        if(b.index < (msgStartIndex + totalMsgSize))
            b.index = (msgStartIndex + totalMsgSize); // could be extensions tacked on at end which we do not support

        return b.index;
    }

    // Read and process alert record.
    bool readAlertMsg(ByteArray b)
    {
        if(b.getNumBytesLeft() < 2)
        {
            logError("Alert msg too small.");
            return false;
        }

        u8 alertLevel = b.readU8();
        u8 alertID    = b.readU8();

        handleAlert(alertLevel, alertID);

        clientSeqNum++;

        return true;
    }

    // handle alert from other
    void handleAlert(u8 alertLevel, u8 alertID)
    {
        if(alertID == TLS:ALERT_NO_ERROR)
        {
            // ignore
            //logInfo("TLS ALERT_NO_ERROR");
        }
        if(alertID == TLS:ALERT_CLOSE_NOTIFY)
        {
            // closing connection normally
            logError("TLS ALERT_CLOSE_NOTIFY");
            socket.disconnect();
        }
        else
        {
            // error
            logError("TLS ALERT: " + TLS:getAlertStr(alertID));
            socket.disconnect();
        }
    }

    // Read and process cipher change record.
    bool readCipherChangeMsg(ByteArray b)
    {
        if(b.getNumBytesLeft() < 1)
        {
            logError("Change cipher msg too small.");
            return false;
        }

        u8 changeTrue = b.readU8();

        if(this.state != STATE_GOT_CLIENT_KEYS)
        {
            logError("Got out of order change cipher spec msg from server!");
            return false;
        }

        clientSeqNum++;

        return true;
    }

    // Read and process app data record.
    bool readAppDataMsg(ByteArray b, u16 msgBodySize)
    {
        if(b.getNumBytesLeft() < msgBodySize)
        {
            logError("App data msg too small.");
            return false;
        }

        if(this.state != STATE_APP_DATA)
        {
            logError("Got TLS:RECORD_TYPE_APP_DATA before state is STATE_APP_DATA!");
            return false;
        }

        // first 16 bytes IV
        u8[16] msgIV;
        for(u64 v=0; v<16; v++)
            msgIV[v] = b.readU8();

        // decrypt rest
        decryptBuffer.clear();
        decryptBuffer.write(b, b.index, msgBodySize - 16);
        decryptRecord(TLS:RECORD_TYPE_APP_DATA, decryptBuffer, msgIV, clientSeqNum, recvAppBuffer);

        clientSeqNum++;

        return true;
    }

    // Client sends hello to server. ciphers = u16[](TLS:CIPHER_RSA_AES128_CBC_SHA256, TLS:CIPHER_RSA_AES256_CBC_SHA256) etc.
    bool readClientHelloMsg(ByteArray b, u32 msgStartIndex, u16 msgBodySize)
    {
        u64 bIndexVerifyData = b.index - TLS:HANDSHAKE_HEADER_SIZE; // finished message verify_data hash needs data (but not record headers) from handshake msgs

        // TLS version we want to agree on
        u8 tlsVerMajor = b.readU8();
        u8 tlsVerMinor = b.readU8(); // could be 4 for TLS "1.3" or even 2 for TLS "1.1" etc.

        if(tlsVerMinor < 3)
        {
            logError("TLS versions before 1.2 not supported.");
            return false;
        }

        // 32 true random bytes - no longer recommended to use first 4 bytes as GMT/UTC time
        this.clientRandoms = u8[](32);
        for(u64 c=0; c<32; c++)
            this.clientRandoms[c] = b.readU8();

        // session id length bytes (if zero, no id bytes written)
        u8 sessionBytesLen = b.readU8();
        if(sessionBytesLen != 0)
        {
            logInfo("TLS sessions not supported, ignoring client session id. ID is " + String<u8>:formatNumber(sessionBytesLen) + " num bytes long.");
            b.index += sessionBytesLen; // just skip over

            //logError("TLS sessions not supported.");
            //return false;
        }

        // ciphers length in bytes as u16
        u16 numCipherBytes = b.readU16();
        u16 numCiphers = numCipherBytes / 2;
        u16[] clientCiphers = u16[](numCiphers);
        for(u64 c=0; c<numCiphers; c++)
        {
            clientCiphers[c] = b.readU16();
        }

        // pick valid cipher
        u16 cipherMatch = 0;
        for(u64 c=0; c<clientCiphers.length(); c++)
        {
            for(u64 s=0; s<allowedCiphers.length(); s++) // allowed ciphers ordered from least secure to most secure
            {
                if(clientCiphers[c] == allowedCiphers[s])
                {
                    cipherMatch = allowedCiphers[s];
                }
            }
        }

        if(cipherMatch != 0)
        {
            this.cipherMode = cipherMatch;
        }
        else
        {
            logError("Server and client cannot agree on cipher mode.");
            return false;
        }

        // compression methods (no one uses)
        u8 numCompressionBytes = b.readU8();
        b.index += numCompressionBytes;

        // skip over extensions
        u64 totalMsgSize = TLS:HEADER_SIZE + msgBodySize;
        if(b.index < (msgStartIndex + totalMsgSize))
            b.index = msgStartIndex + totalMsgSize; // could be extensions tacked on at end which we do not support

        this.handshakeMsgs.write(b, bIndexVerifyData, b.index - bIndexVerifyData);
        clientSeqNum++;

        return true;
    }

    // Client sends key parameters. preMasterSecret is 48 bytes always with the first two bytes being the protocol version (TLS 1.2 = "3, 3").
    bool readClientKeyExchangeRSAMsg(ByteArray b, u32 msgStartIndex, u16 msgBodySize)
    {
        u64 bIndexVerifyData = b.index - TLS:HANDSHAKE_HEADER_SIZE; // finished message verify_data hash needs data (but not record headers) from handshake msgs

        b.setBigEndian();
        u16 pmsLen = b.readU16();
        u8[] encryptedPMS(pmsLen);
        for(u64 e=0; e<pmsLen; e++)
            encryptedPMS[e] = b.readU8();

        // decrypt pre master secret
        this.preMasterSecret = rsaPrivateKey.decryptPKCS1(encryptedPMS);
        if(this.preMasterSecret == null)
        {
            logError("Failed to decrypt premaster secret.");
            return false;
        }

        if(this.preMasterSecret.length() != TLS:PREMASTER_SECRET_SIZE)
        {
            logError("Failed to decrypt premaster secret as 48 bytes.");
            return false;
        }

        // generate keys etc.
        this.masterSecret    = TLS:generateMasterSecret(this.clientRandoms, this.serverRandoms, this.preMasterSecret);
        this.keys            = TLS:generateKeysFromMasterSecret(this.cipherMode, this.clientRandoms, this.serverRandoms, this.masterSecret);
        this.clientDecrypter = AES:createCBC(keys.clientKey); // CBC mode
        this.serverEncrypter = AES:createCBC(keys.serverKey); // CBC mode

        // skip over extensions
        u64 totalMsgSize = TLS:HEADER_SIZE + msgBodySize;
        if(b.index < (msgStartIndex + totalMsgSize))
            b.index = msgStartIndex + totalMsgSize; // could be extensions tacked on at end which we do not support

        this.handshakeMsgs.write(b, bIndexVerifyData, b.index - bIndexVerifyData);
        clientSeqNum++;

        return true;
    }

    // Client sends verification (encrypted/MAC) data using emphereal keys.
    bool readClientHandshakeVerifyMsg(ByteArray b, u32 msgStartIndex, u16 msgBodySize)
    {
        u64 bIndexVerifyData = b.index - TLS:HANDSHAKE_HEADER_SIZE; // finished message verify_data hash needs data (but not record headers) from handshake msgs

        b.setBigEndian();

        u8[16] msgIV;
        for(u64 a=0; a<16; a++)
            msgIV[a] = b.readU8();

        // decrypt rest
        ByteArray decrypted();
        decryptBuffer.clear();
        decryptBuffer.write(b, b.index, msgBodySize - 16);
        clientSeqNum = 0; // first message encrypted is SeqNum=0 and HANDSHAKE_FINISHED is first client encrypted msg
        decryptRecord(TLS:RECORD_TYPE_HANDSHAKE, decryptBuffer, msgIV, clientSeqNum, decrypted);
        decrypted.index = 0;

        if(decrypted.size() < 16) // header (4) + verify bytes (12)
        {
            logError("TLSServer.readClientHandshakeVerifyMsg() decrypted.size() < 16");
            return false;
        }

        // another header, 4 bytes total
        u8  handshakeHeaderID = decrypted.readU8();
        u32 handshakeBodySize = (u32(decrypted.readU8()) << 16) | (u32(decrypted.readU8()) << 8) | (u32(decrypted.readU8()));

        if(handshakeHeaderID != TLS:HANDSHAKE_FINISHED)
        {
            logError("TLSServer.readClientHandshakeVerifyMsg() handshakeHeaderID != TLS:HANDSHAKE_FINISHED, handshakeID: " + String<u8>:formatNumber(handshakeHeaderID));
            return false;
        }

        // Read verify data
        u8[12] clientVerifyData;
        for(u64 v=0; v<12; v++)
            clientVerifyData[v] = decrypted.readU8();

        // Verify Data
        // The verify_data is built from the master secret and the hash of the payload of all handshake records (type=0x16) previous to this one. 
        // The calculation for verify_data is as follows:
        // 
        // seed = "client finished" + SHA256(all handshake messages)
        // a0 = seed
        // a1 = HMAC-SHA256(key=MasterSecret, data=a0)
        // p1 = HMAC-SHA256(key=MasterSecret, data=a1 + seed)
        // verify_data = p1[first 12 bytes]
        //
        //handshake_messages
        // All of the data from all messages in this handshake (not
        // including any HelloRequest messages) up to, but not including,
        // this message.  This is only data visible at the handshake layer
        // and does not include record layer headers.  This is the
        // concatenation of all the Handshake structures as defined in
        // Section 7.4, exchanged thus far.

        u8[] msg(Chars:c, Chars:l, Chars:i, Chars:e, Chars:n, Chars:t, Chars:SPACE, Chars:f, Chars:i, Chars:n, Chars:i, Chars:s, Chars:h, Chars:e, Chars:d); // "client finished"
        u8[32] handshakeMsgsHash = Hashing:hashSHA256(this.handshakeMsgs);
        u8[] seed(msg.length() + 32);
        for(u64 m=0; m<msg.length(); m++)
            seed[m] = msg[m];
        for(u64 q=0; q<32; q++)
            seed[msg.length() + q] = handshakeMsgsHash[q];

        u8[] handHashArray(32);
        for(u64 t=0; t<32; t++)
            handHashArray[t] = handshakeMsgsHash[t];

        // Hashed Message Authentication Cryptography. Returns message digest (based on hashing and xor operations). See RFC 2104.
        u8[] a1 = TLS:hmacArray(masterSecret, seed, seed.length(), Hashing:HASH_SHA256);

        u8[] dataA1Seed(a1.length() + seed.length());
        for(u64 a=0; a<a1.length(); a++)
            dataA1Seed[a] = a1[a];
        for(u64 s=0; s<seed.length(); s++)
            dataA1Seed[a1.length() + s] = seed[s];

        u8[] p1 = TLS:hmacArray(masterSecret, dataA1Seed, dataA1Seed.length(), Hashing:HASH_SHA256);

        u8[12] serverVerifyData;
        for(u64 p=0; p<12; p++)
            serverVerifyData[p] = p1[p];

        // check verify
        bool verifyMatch = true;
        for(u64 v=0; v<12; v++)
        {
            if(clientVerifyData[v] != serverVerifyData[v])
                verifyMatch = false;
        }

        if(verifyMatch == false)
        {
            logError("TLSServer.readClientHandshakeVerifyMsg() Client and server verify data does not match!");
            ByteArray clientVD();
            ByteArray serverVD();
            for(u64 y=0; y<12; y++)
            {
                clientVD.writeU8(clientVerifyData[y]);
                serverVD.writeU8(serverVerifyData[y]);
            }
            logError("TLSServer.readClientHandshakeVerifyMsg() Client sent: " + ByteArray(clientVD).toHexString());
            logError("TLSServer.readClientHandshakeVerifyMsg() Server calc: " + ByteArray(serverVD).toHexString());
            return false;
        }

        // update handshake data for use by server verification msg (not this client->server msg)
        this.handshakeMsgs.write(decrypted, 0, decrypted.numUsed);

        // no extensions supported, so no extra bytes
        clientSeqNum++;
        
        return true;
    }

    // Server sends alert message. level is 1 or 2
    void writeAlertMsg(ByteArray b, u8 level, u8 alertID)
    {
        // header
        b.writeU8(TLS:RECORD_TYPE_ALERT); // record ID
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(tlsVer); // version "minor"
        b.writeU8(0); // record length in bytes (high bits of u16)
        b.writeU8(2); // record length in bytes (low bits of u16)

        // alert body
        b.writeU8(level);
        b.writeU8(alertID);
        serverSeqNum++;
    }

    // Server sends change cipher spec message.
    void writeChangeCipherMsg(ByteArray b)
    {
        // header
        b.writeU8(TLS:RECORD_TYPE_CHANGE_CIPHER); // record ID
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(tlsVer); // version "minor"
        b.writeU8(0); // record length in bytes (high bits of u16)
        b.writeU8(1); // record length in bytes (low bits of u16)

        // change body
        b.writeU8(1); // "true"
        serverSeqNum++;
    }

    // Server sends app data message.
    bool writeAppDataMsg(ByteArray b, u8[16] iv, u8[] data, u64 index, u16 numBytes)
    {
        // header
        b.writeU8(TLS:RECORD_TYPE_APP_DATA); // record ID
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(tlsVer); // version "minor"
        u64 lenIndex = b.index;
        b.writeU8((numBytes & 0xFF00) >> 8); // record length in bytes (high bits of u16)
        b.writeU8((numBytes & 0x00FF)); // record length in bytes (low bits of u16)

        // IV (kinda part of header)
        for(u64 v=0; v<16; v++)
            b.writeU8(iv[v]);

        // after IV everything encrypted
        this.encryptBuffer.clear();
        this.encryptBuffer.write(data, index, numBytes);
        this.encryptRecord(this.encryptBuffer, iv, serverSeqNum, TLS:RECORD_TYPE_APP_DATA, encryptBuffer.size());
        
        // write encrypted data
        for(u64 v=0; v<encryptBuffer.size(); v++)
            b.writeU8(encryptBuffer[v]);

        // update length (excludes header)
        u16 msgBodyLen = b.index - (lenIndex + 2); // + 2 because length bytes not included
        b.writeU8(lenIndex + 0, (msgBodyLen & 0xFF00) >> 8); // high byte
        b.writeU8(lenIndex + 1, (msgBodyLen & 0x00FF)); // low byte

        serverSeqNum++;

        return true;
    }

    // Write server hello msg.
    bool writeServerHelloMsg(ByteArray b)
    {
        // header
        b.writeU8(TLS:RECORD_TYPE_HANDSHAKE); // record ID
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(TLS:VER_1_2); // version "minor" - minimum we support is 1.2, but some 1.2 servers fail is client isn't 1.0 to start (?!) others fail if this isn't 1.2 (the correct version).
        u64 lenIndex = b.index;
        b.writeU8(0); // record length in bytes (high bits of u16)
        b.writeU8(0); // record length in bytes (low bits of u16)

        u64 bIndexVerifyData = b.index; // finished message verify_data hash needs data (but not record headers) from handshake msgs

        // handshake header is id (1 byte) + length of data to follow (3 bytes)
        b.writeU8(TLS:HANDSHAKE_SERVER_HELLO);

        // length 2 (because...reasons)
        u64 len2Index = b.index;
        b.writeU8(0);
        b.writeU8(0);
        b.writeU8(0);

        // TLS version we agree on
        b.writeU8(0x03);
        b.writeU8(0x03); // 1.2 only baby!

        // 32 bytes of random
        this.serverRandoms = TLS:generateTrueRandomBytes(32);
        for(u64 r=0; r<32; r++)
            b.writeU8(this.serverRandoms[r]);

        // session len
        b.writeU8(0); // no sessions support

        // choosen cipher mode
        b.writeU16(this.cipherMode);

        // compression, must be zero for us
        b.writeU8(0);

        // no extensions

        // update length (excludes header)
        u16 msgBodyLen = b.index - (lenIndex + 2); // + 2 because length bytes not included
        b.writeU8(lenIndex + 0, (msgBodyLen & 0xFF00) >> 8); // high byte
        b.writeU8(lenIndex + 1, (msgBodyLen & 0x00FF)); // low byte

        // update length 2 (excludes header and handshake header - yes two headers)
        u16 msgBody2Len = b.index - (len2Index + 3); // + 3 because 3-byte length not included
        b.writeU8(len2Index + 0, 0); // assume high byte is 0
        b.writeU8(len2Index + 1, (msgBody2Len & 0xFF00) >> 8); // high byte
        b.writeU8(len2Index + 2, (msgBody2Len & 0x00FF)); // low byte

        // keep track of handshake messages data for verify later
        this.handshakeMsgs.write(b, bIndexVerifyData, b.index - bIndexVerifyData);

        serverSeqNum++;

        return true;
    }

    // Write server certificate msg.
    bool writeServerCertsMsg(ByteArray b)
    {
        // header
        b.writeU8(TLS:RECORD_TYPE_HANDSHAKE); // record ID
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(TLS:VER_1_2); // version "minor" - minimum we support is 1.2, but some 1.2 servers fail is client isn't 1.0 to start (?!) others fail if this isn't 1.2 (the correct version).
        u64 lenIndex = b.index;
        b.writeU8(0); // record length in bytes (high bits of u16)
        b.writeU8(0); // record length in bytes (low bits of u16)

        u64 bIndexVerifyData = b.index; // finished message verify_data hash needs data (but not record headers) from handshake msgs

        // handshake header is id (1 byte) + length of data to follow (3 bytes)
        b.writeU8(TLS:HANDSHAKE_SERVER_CERTIFICATE);

        // length 2 (because...reasons)
        u64 len2Index = b.index;
        b.writeU8(0);
        b.writeU8(0);
        b.writeU8(0);

        // length 3 for certs files size
        u64 len3Index = b.index;
        b.writeU8(0);
        b.writeU8(0);
        b.writeU8(0);

        //b.write(this.serverCertChain); // binary DER files
        for(u64 c=0; c<serverCertFiles.size(); c++)
        {
            // each cert gets a length
            ByteArray certFile = serverCertFiles[c];
            b.writeU8((certFile.numUsed >> 16) & 0xFF);
            b.writeU8((certFile.numUsed >> 8) & 0xFF);
            b.writeU8((certFile.numUsed) & 0xFF);

            b.write(certFile);
        }

        // update length (excludes header)
        u16 msgBodyLen = b.index - (lenIndex + 2); // + 2 because length bytes not included
        b.writeU8(lenIndex + 0, (msgBodyLen & 0xFF00) >> 8); // high byte
        b.writeU8(lenIndex + 1, (msgBodyLen & 0x00FF)); // low byte

        // update length 2 (excludes header and handshake header - yes two headers)
        u16 msgBody2Len = b.index - (len2Index + 3); // + 3 because 3-byte length not included
        b.writeU8(len2Index + 0, 0); // assume high byte is 0
        b.writeU8(len2Index + 1, (msgBody2Len & 0xFF00) >> 8); // high byte
        b.writeU8(len2Index + 2, (msgBody2Len & 0x00FF)); // low byte

        // update length 3 cert files
        u16 msgBody3Len = b.index - (len3Index + 3); // + 3 because 3-byte length not included
        b.writeU8(len3Index + 0, 0); // assume high byte is 0
        b.writeU8(len3Index + 1, (msgBody3Len & 0xFF00) >> 8); // high byte
        b.writeU8(len3Index + 2, (msgBody3Len & 0x00FF)); // low byte

        // track handshakes msgs
        this.handshakeMsgs.write(b, bIndexVerifyData, b.index - bIndexVerifyData);

        serverSeqNum++;

        return true;
    }

    // Write server handshake hello done msg.
    bool writeHandshakeServerHelloDoneMsg(ByteArray b)
    {
        // header
        b.writeU8(TLS:RECORD_TYPE_HANDSHAKE); // record ID
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(TLS:VER_1_2); // version "minor" - minimum we support is 1.2, but some 1.2 servers fail is client isn't 1.0 to start (?!) others fail if this isn't 1.2 (the correct version).
        u64 lenIndex = b.index;
        b.writeU8(0); // record length in bytes (high bits of u16)
        b.writeU8(0); // record length in bytes (low bits of u16)

        u64 bIndexVerifyData = b.index; // finished message verify_data hash needs data (but not record headers) from handshake msgs

        // handshake header is id (1 byte) + length of data to follow (3 bytes)
        b.writeU8(TLS:HANDSHAKE_SERVER_HELLO_DONE);

        // length 2 (because...reasons)
        u64 len2Index = b.index;
        b.writeU8(0);
        b.writeU8(0);
        b.writeU8(0);

        // update length (excludes header)
        u16 msgBodyLen = b.index - (lenIndex + 2); // + 2 because length bytes not included
        b.writeU8(lenIndex + 0, (msgBodyLen & 0xFF00) >> 8); // high byte
        b.writeU8(lenIndex + 1, (msgBodyLen & 0x00FF)); // low byte

        // update length 2 (excludes header and handshake header - yes two headers)
        u16 msgBody2Len = b.index - (len2Index + 3); // + 3 because 3-byte length not included
        b.writeU8(len2Index + 0, 0); // assume high byte is 0
        b.writeU8(len2Index + 1, (msgBody2Len & 0xFF00) >> 8); // high byte
        b.writeU8(len2Index + 2, (msgBody2Len & 0x00FF)); // low byte

        // track handshakes msgs
        this.handshakeMsgs.write(b, bIndexVerifyData, b.index - bIndexVerifyData);

        serverSeqNum++;

        return true;
    }

    // Write server verification message (which is encrypted).
    bool writeServerHandshakeVerifyMsg(ByteArray b)
    {
        // header
        b.writeU8(TLS:RECORD_TYPE_HANDSHAKE); // record ID
        b.writeU8(0x03); // version major, always 0x03 because of SSL3.0
        b.writeU8(tlsVer); // version "minor"
        u64 lenIndex = b.index;
        b.writeU8(0); // record length in bytes (high bits of u16)
        b.writeU8(2); // record length in bytes (low bits of u16)

        // 16 byte initialization vector comes before header
        u8[16] initVec = TLS:generateIV();
        for(u64 v=0; v<16; v++)
            b.writeU8(initVec[v]);

        // the rest is encrypted
        encryptBuffer.clear();
        encryptBuffer.setBigEndian();

        // handshake header is id (1 byte) + length of data to follow (3 bytes)
        encryptBuffer.writeU8(TLS:HANDSHAKE_FINISHED);

        // length 2
        u64 len2Index = encryptBuffer.index;
        encryptBuffer.writeU8(0);
        encryptBuffer.writeU8(0);
        encryptBuffer.writeU8(12);

        // calculate our verify
        u8[] msg(Chars:s, Chars:e, Chars:r, Chars:v, Chars:e, Chars:r, Chars:SPACE, Chars:f, Chars:i, Chars:n, Chars:i, Chars:s, Chars:h, Chars:e, Chars:d); // "server finished"
        u8[32] handshakeMsgsHash = Hashing:hashSHA256(this.handshakeMsgs);
        u8[] seed(msg.length() + 32);
        for(u64 m=0; m<msg.length(); m++)
            seed[m] = msg[m];
        for(u64 q=0; q<32; q++)
            seed[msg.length() + q] = handshakeMsgsHash[q];

        u8[] handHashArray(32);
        for(u64 t=0; t<32; t++)
            handHashArray[t] = handshakeMsgsHash[t];

        // Hashed Message Authentication Cryptography. Returns message digest (based on hashing and xor operations). See RFC 2104.
        u8[] a1 = TLS:hmacArray(masterSecret, seed, seed.length(), Hashing:HASH_SHA256);

        u8[] dataA1Seed(a1.length() + seed.length());
        for(u64 a=0; a<a1.length(); a++)
            dataA1Seed[a] = a1[a];
        for(u64 s=0; s<seed.length(); s++)
            dataA1Seed[a1.length() + s] = seed[s];

        u8[] verifyData = TLS:hmacArray(masterSecret, dataA1Seed, dataA1Seed.length(), Hashing:HASH_SHA256);

        if(verifyData.length() < 12)
        {
            logError("Unable to calculate verify data!");
            return false;
        }

        // write verify data
        for(u64 v=0; v<12; v++)
            encryptBuffer.writeU8(verifyData[v]);

        // encrypt encryptBuffer and append encrypted bytes to b buffer
        serverSeqNum = 0; // first message encrypted is SeqNum=0 and HANDSHAKE_FINISHED is first encrypted message for server
        this.encryptRecord(encryptBuffer, initVec, serverSeqNum, TLS:RECORD_TYPE_HANDSHAKE, 16); // record size should be entire payload (handshake record header included)

        // write encrypted data
        for(u64 v=0; v<encryptBuffer.size(); v++)
            b.writeU8(encryptBuffer[v]);

        serverSeqNum++;

        // update length (excludes header)
        u16 msgBodyLen = b.index - (lenIndex + 2); // + 2 because length bytes not included
        b.writeU8(lenIndex + 0, (msgBodyLen & 0xFF00) >> 8); // high byte
        b.writeU8(lenIndex + 1, (msgBodyLen & 0x00FF)); // low byte

        return true;
    }

    // Encrypt data record, appending MAC and padding before encrypting.
    void encryptRecord(ByteArray data, u8[16] iv, u64 sequenceNumber, u8 recordType, u32 recordLength)
    {
        u64 MAC_LEN = 20;
        u64 PAD_TO  = 16;

        data.index = data.numUsed;

        u8[64] macBuf = TLS:calcMsgMAC(TLS:getHashFuncType(this.cipherMode), keys.serverKeyMAC, sequenceNumber, recordType, recordLength, data);
        for(u64 i=0; i<MAC_LEN; i++)
            data.writeU8(macBuf[i]); // append msg code

        // So TLS 1.2 uses PKCS7 padding, but also there is a single byte length of padding 
        // field at the end of the data (after MAC). Why? An attempt at backwards compatibility
        // with SSLv2/3.
        u64 numPadBytes = PAD_TO - ((data.size()+1) % PAD_TO);
        if(numPadBytes == 0)
            numPadBytes = PAD_TO; // one whole block of padding
        data.writeU8(numPadBytes); // this will be the same value as what PKCS7 writes out
        PKCS7:pad(data, PAD_TO);

        serverEncrypter.setIV(iv); // each message choose an IV
        serverEncrypter.encrypt(data.data, data.size());
    }

    // Decrypt data record, verifying MAC. Returns null if failed (MAC failure etc.).
    void decryptRecord(u8 recordType, ByteArray data, u8[16] iv, u64 sequenceNumber, ByteArray outData)
    {
        u64 MAC_LEN = 20;
        u64 PAD_TO  = 16;

        if(data == null)
        {
            logError("TLSServer.decryptRecord() data=null");
            return;
        }

        if(data.size() == 0)
        {
            logError("TLSServer.decryptRecord() data.size() = 0"); // Forbidden in TLS
            return;
        }

        if((data.size() % PAD_TO) != 0)
        {
            logError("TLSServer.decryptRecord() (data.size() % PAD_TO) != 0"); // Since we only support AES 128/256 which have block sizes of 16
            return;
        }

        clientDecrypter.setIV(iv); // each message choose an IV
        clientDecrypter.decrypt(data.data, data.numUsed);

        PKCS7:unpad(data, PAD_TO);
        if(data.size() == 0)
        {
            logError("TLSServer.decryptRecord() bad padding");
            return;
        }

        // minimum record size is HEADER + MAC
        if(data.size() < MAC_LEN)
        {
            logError("TLSServer.decryptRecord() unpaddedData too small (MAC minimum)");
            return;
        }

        u8[64] recordMAC;
        for(u64 m=0; m<MAC_LEN; m++)
            recordMAC[m] = data[(data.size() - 21) + m]; // -21 because last byte isn't part of HMAC it's just a byte specifying padding (outside of PKCS7)

        outData.write(data, 0, data.size() - 21);
        u32 recordLength = outData.size(); // -1 because of last byte indicating padding (but not part of PKCS7) // (u32(unpaddedData[1]) << 16) | (u32(unpaddedData[2]) << 8) | (u32(unpaddedData[3]));

        // MAC must be last 20 bytes
        u8[64] checkMAC = TLS:calcMsgMAC(TLS:getHashFuncType(this.cipherMode), keys.clientKeyMAC, sequenceNumber, recordType, recordLength, outData);

        bool badMAC = false;
        for(u64 m=0; m<MAC_LEN; m++)
        {
            if(recordMAC[m] != checkMAC[m])
                badMAC = true;
        }

        if(badMAC == true)
        {
            logError("TLSServer.decryptRecord() checkMAC != recordMAC, bad MAC.");
            return;
        }
    }
}