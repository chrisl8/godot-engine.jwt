extends JWTBaseBuilder
class_name JWTVerifierBuilder

var algorithm: JWTAlgorithm
var claims: Dictionary = {}
var leeway: int = 0
var ignore_issued_at: bool = false

func _init(algorithm: JWTAlgorithm):
    self.algorithm = algorithm

func add_claim(name: String, value) -> void:
    match typeof(value):
        TYPE_ARRAY, TYPE_STRING_ARRAY: 
            if value.size() == 0 : 
                self.claims.erase(name)
                return
        TYPE_STRING: 
            if value.length() == 0: 
                self.claims.erase(name)
                return
        _:  
            if value == null:
                self.claims.erase(name)
                return
    self.claims[name] = value

func with_any_of_issuers(issuers: PoolStringArray) -> JWTVerifierBuilder:
    add_claim(JWTClaims.Public.ISSUER, issuers)
    return self

func with_any_of_audience(audience: PoolStringArray) -> JWTVerifierBuilder:
    add_claim(JWTClaims.Public.AUDIENCE, audience)
    return self

func accept_leeway(leeway: int) -> JWTVerifierBuilder:
    self.leeway = leeway
    return self

func accept_expire_at(leeway: int) -> JWTVerifierBuilder:
    with_expires_at(leeway)
    return self

func accept_not_before(leeway: int) -> JWTVerifierBuilder:
    with_not_before(leeway)
    return self

func accept_issued_at(leeway: int) -> JWTVerifierBuilder:
    with_issued_at(leeway)
    return self

func ignore_issued_at() -> JWTVerifierBuilder:
    self.ignore_issued_at = true
    return self

func with_claim_presence(claim_name: String) -> JWTVerifierBuilder:
    add_claim(claim_name, null)
    return self

func _add_leeway() -> void:
    if (not claims.has(JWTClaims.Public.EXPRIES_AT)):
        claims[JWTClaims.Public.EXPRIES_AT] = self.leeway
    if (not claims.has(JWTClaims.Public.NOT_BEFORE)):
        claims[JWTClaims.Public.NOT_BEFORE] = self.leeway
    if (not claims.has(JWTClaims.Public.ISSUED_AT)):
        claims[JWTClaims.Public.ISSUED_AT] = self.leeway
    if (ignore_issued_at):
        claims.erase(JWTClaims.Public.ISSUED_AT)
    
func build(clock: int = OS.get_unix_time()) -> JWTVerifier:
    _add_leeway()
    return JWTVerifier.new(self.algorithm, self.claims, clock)
