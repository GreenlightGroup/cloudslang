########################################################################################################################
#!!
#! @input tenant_id: MS Azure Active Directory Tenant ID
#! @input client_id: App ID of Azure AD registered application
#! @input client_secret: Key generated for App ID listed here as client_id
#!!#
########################################################################################################################
namespace: GLG-Core.MSAzure.Operations
flow:
  name: MSAzure_GetADToken
  inputs:
    - tenant_id: "${get_sp('GLG-Core.tenant_id')}"
    - client_id: "${get_sp('GLG-Core.client_id')}"
    - client_secret:
        default: "${get_sp('GLG-Core.client_secret')}"
        sensitive: true
  workflow:
    - http_client_post:
        do:
          io.cloudslang.base.http.http_client_post:
            - url: "${'https://login.microsoftonline.com/' + get_sp('GLG-Core.tenant_id') + '/oauth2/token'}"
            - body: "${'grant_type=client_credentials&resource=https://management.azure.com&client_id=' + get_sp('GLG-Core.client_id') + '&client_secret=' + get_sp('GLG-Core.client_secret')}"
            - content_type: application/x-www-form-urlencoded
        publish:
          - response: '${return_result}'
        navigate:
          - SUCCESS: match_regex
          - FAILURE: on_failure
    - match_regex:
        do:
          io.cloudslang.base.strings.match_regex:
            - regex: '"token_type":"(.*?)"'
            - text: '${response}'
        publish:
          - match_text
        navigate:
          - MATCH: SUCCESS
          - NO_MATCH: FAILURE
  outputs:
    - authToken
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      http_client_post:
        x: 100
        y: 250
      match_regex:
        x: 400
        y: 250
        navigate:
          f3500694-1cf3-012d-c71a-8975b31ccaef:
            targetId: b5a4ef35-cdd9-6d95-a177-818d827d1a69
            port: MATCH
          c84d8ab8-2e66-b0b2-844c-a7f07346acea:
            targetId: 6736cea6-2e73-afc4-a054-397bc70ff837
            port: NO_MATCH
    results:
      SUCCESS:
        b5a4ef35-cdd9-6d95-a177-818d827d1a69:
          x: 700
          y: 125
      FAILURE:
        6736cea6-2e73-afc4-a054-397bc70ff837:
          x: 700
          y: 375
