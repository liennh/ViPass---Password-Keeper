//
//  Singleton.swift
//  SwiftRSA
//
//  Created by Giacomo Leopizzi on 06/05/2017.
//
//

import Foundation
final class Singleton {
    
    static let shared = Singleton()
    
    private init() { }
    
    /*public var key: RSA.Key = {
        return RSA.Key.generate(keyPairWithLenght: 2048)
    }()*/
    
    public let privateKey =
    """
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC9K8cTnknuW+4i
U7pYuWYyTOgNiFkiHl7IEqfEIQ/xVQl9mJor+VBpYv0M1vkz99p4J+L04yNTurdT
4+sCWOfxpZp7sMEV8S0uImA5MQdECRoa5XDmZCedjVDSXY2hvnMeEEMGNr4KF1DU
rQLOByyoWpf37mzpQ9vfSzURldaHYdWjMEcmYttrofnnKzp/UaAu7RioQqhOj+r2
fe2YSSIJUPdbLna1RDcaw8+4QRPQK70OVY1Y9IVbk3QAKtruxa4ASnQpZY/B5hj7
7ivG18cnCWYjvBo8cIhn7LsVFkDhcAuLojJJXCu2tvJnjrbbeTKN7dGEgNSxcoRl
skvIbN8VAgMBAAECggEATtCzg9f6Q4YnxEOQKzErhB+Iu0KoqE9w+/jRzyRbSRg9
+QcgjNu2BgKJHdVfRKiqbE9p/s+3w0XS5e/a1UKHeKWfpJMzD1pJkaQe5RUpSs5k
Avq/PC5UVw8uskbqII6B1e++jRM3wGqQcduXhJF2qLn+AP1kgReVvwXNmYMNO5/u
z5c4TJb3q32x4sub1PFeEclxaKMFObfj4+6nA7QEPexIJeT3GaULWkFUM7Fh9wL1
uEqTLPkAPeUmkQiWZj8VwUwDfALTbxoipLMJZHShdphrabQUTIGjeRywMH6gtHKw
lv+DtMsnNutlkIDIdLDMHloCcVb+65ypoVNGTPYRLQKBgQDnfQ2KOkD4gJIkxiAb
amhCf9Ldmj9Os5KD5dUas7JbT0mUYv7eZKV4d9dCbGXO4f4LalF2RdfkfnlVZDty
GQeRbJNCSjBf0MhWInh5saeuhc/Rgr7ha5HVwLykS+KVun7Ehob1xXAuK6Q6lMrk
2KkUmf1nKb4CPP5Kbba7/FIpMwKBgQDRM6B5jSL2T91VCRDCdvDRxViMW+RWQF1P
Gk+sByDXam9JOPXvbVE/CDYZWTFGS6dVyS2QM7C2qbEsqVAMgX+h/0iheBehnKpG
dLZ9RmGb/4jvcum4gXWbddLuNO3KYaYMJ1XrveuiUXkmqYmKzJBDA1xZVagXA0RC
PPDeIMMmlwKBgDaTYgzTvRuZXFs1Jr6v8JK1BibexcwtQ/66wepAsW0bnVJRoJsY
CXcEcgij+8CxwS45y6jhwIuLUdnS/rzgr8sWWQWI7iy40XKVP+gY/VqFC8DuXUhS
DxjhDtiBV5NLW7XDra/l85O/EEILcGZRulM0Fu0qhzSJ4r3zbeCWFVzHAoGAdary
Miw+ZAib136X3KmF3pd/rMLq9dCSKzIDaiFASanmGmtdeWQldKyrsSpH2uAmqMvV
QuywEq3zp8k76yzTm0y5j4i60f4KkEKJeoEh2dqrLPOXnl3CxsRI9g7zSQgPm3ps
i4JxjQUCfcqSQG27HtY/FUhmmTsPI6qfWHFZEtUCgYBodSR5YV2E8fgD2gVaB/3F
PagLzJCmHfrwmWwu41qj/oNZyr8ASVPNhUiPzw2+svqSmM7/bMLPOaqy9NpoD0to
VkLY8xN6OxJ95Lm2cW3UeCq16P2r1AO2b94pxClcCtGU2X90F0xzGiK6qzuFTu6b
0CxhZxs7EFcP90TG1wXhNQ==
-----END PRIVATE KEY-----
"""
    
    
    public let publicKey =
    """
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvSvHE55J7lvuIlO6WLlm
MkzoDYhZIh5eyBKnxCEP8VUJfZiaK/lQaWL9DNb5M/faeCfi9OMjU7q3U+PrAljn
8aWae7DBFfEtLiJgOTEHRAkaGuVw5mQnnY1Q0l2Nob5zHhBDBja+ChdQ1K0Czgcs
qFqX9+5s6UPb30s1EZXWh2HVozBHJmLba6H55ys6f1GgLu0YqEKoTo/q9n3tmEki
CVD3Wy52tUQ3GsPPuEET0Cu9DlWNWPSFW5N0ACra7sWuAEp0KWWPweYY++4rxtfH
JwlmI7waPHCIZ+y7FRZA4XALi6IySVwrtrbyZ46223kyje3RhIDUsXKEZbJLyGzf
FQIDAQAB
-----END PUBLIC KEY-----
"""
    
}
