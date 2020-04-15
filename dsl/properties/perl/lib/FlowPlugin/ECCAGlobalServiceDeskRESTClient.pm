## DO NOT EDIT THIS BLOCK === rest client imports starts ===
package FlowPlugin::ECCAGlobalServiceDeskRESTClient;
use strict;
use warnings;
use LWP::UserAgent;
use JSON;
use Data::Dumper;
use FlowPDF::Client::REST;
use FlowPDF::Log;
## DO NOT EDIT THIS BLOCK === rest client imports ends, checksum: ad87fa5ec430d319224c067bb0cc4e0f ===
# Place for the custom user imports, e.g. use File::Spec
use Tie::IxHash;
use XML::Simple;
use DateTime::Format::ISO8601;
## DO NOT EDIT THIS BLOCK === rest client starts ===
=head1

FlowPlugin::ECCAGlobalServiceDeskRESTClient->new('http://endpoint', {
    auth => {basicAuth => {userName => 'admin', password => 'changeme'}}
})

=cut

# Generated
use constant {
    BEARER_PREFIX => 'Bearer',
    USER_AGENT => 'ECCAGlobalServiceDeskRESTClient REST Client',
    OAUTH1_SIGNATURE_METHOD =>  'RSA-SHA1' ,
    CONTENT_TYPE => 'application/json'
};

=pod

Use this method to create a new FlowPlugin::ECCAGlobalServiceDeskRESTClient, e.g.

    my $client = FlowPlugin::ECCAGlobalServiceDeskRESTClient->new($endpoint,
        basicAuth => {userName => 'user', password => 'password'}
    );

    my $client = FlowPlugin::ECCAGlobalServiceDeskRESTClient->new($endpoint,
        bearerAuth => {token => 'token'}
    )

    my $client = FlowPlugin::ECCAGlobalServiceDeskRESTClient->new($endpoint,
        bearerAuth => {token => 'token'},
        proxy => {url => 'proxy url', username => 'proxy user', password => 'password'}
    )

=cut

sub new {
    my ($class, $endpoint, %params) = @_;

    my $self = { %params };
    $self->{endpoint} = $endpoint;
    if ($self->{basicAuth}) {
        logDebug("Basic Auth Scheme");
        unless($self->{basicAuth}->{userName}) {
            die "No username was provided for the Basic auth";
        }
        unless($self->{basicAuth}->{password}) {
            die "No password was provided for the Basic auth";
        }
    }
    elsif ($self->{bearerAuth}) {
        logDebug("Bearer Auth Scheme");
        unless($self->{bearerAuth}->{token}) {
            die 'No token was provided for the Bearer auth';
        }
    }
    elsif ($self->{oauth1}) {
        logDebug("OAuth 1.0 Auth Scheme");
        unless($self->{oauth1}->{token}) {
            die 'No token is provided for OAuth1 scheme';
        }
        unless($self->{oauth1}->{consumerKey}) {
            die 'No consumerKey is provided for Oauth1 scheme';
        }
        unless ($self->{oauth1}->{privateKey}) {
            die 'No privateKey is provided for oauth1 scheme';
        }
    }
    if ($self->{proxy}) {
        my $url = $self->{proxy}->{url};
        unless($url) {
            die "No URL was provided for the proxy configuration";
        }
        if ($self->{proxy}->{username} && !$self->{proxy}->{password}) {
            die "Username and password should be provided for the proxy auth";
        }
    }

    return bless $self, $class;
}

# This is the simplified form to create the REST client object directly from the plugin configuration
sub createFromConfig {
    my ($class, $configParams) = @_;

    my $endpoint = $configParams->{endpoint};

    my %construction_params = ();
    if  ($configParams->{httpProxyUrl}) {
        $construction_params{proxy} = {
            url => $configParams->{httpProxyUrl},
            username => $configParams->{proxy_user},
            password => $configParams->{proxy_password},
        }
    }
    unless($endpoint) {
        die "No endpoint parameter is provided";
    }
    if ($configParams->{basic_user} && $configParams->{basic_password}) {
        $construction_params{basicAuth} = {
            userName => $configParams->{basic_user},
            password => $configParams->{basic_password}
        };
        return $class->new($endpoint, %construction_params);
    }
    elsif ($configParams->{bearer_password}) {
        $construction_params{bearerAuth} = {
            token => $configParams->{bearer_password},
        };
        return $class->new($endpoint, %construction_params);
    }
    elsif ($configParams->{authScheme} && $configParams->{authScheme} eq 'anonymous') {
        return $class->new($endpoint, %construction_params);
    }
    elsif ($configParams->{oauth1_user}) {
        $construction_params{oauth1} = {
            privateKey => $configParams->{oauth1_password},
            token => $configParams->{oauth1_user},
            consumerKey => $configParams->{oauth1ConsumerKey},
        };
        return $class->new($endpoint, %construction_params);
    }
    return $class->new($endpoint, %$configParams, %construction_params);
}

sub makeRequest {
    my ($self, $method, $uri, $query, $payload, $headers, $params) = @_;

    my $request = $self->createRequest($method, $uri, $query, $payload, $headers);
    logDebug("Request before augment", $request);
    # generic augment
    $request = $self->augmentRequest($request, $params);
    logDebug("Request after augment", $request);
    my $response = $self->rest->doRequest($request);
    logDebug("Response", $response);
    my $retval = $self->processResponse($response, $params);
    if ($retval) {
        return $retval;
    }
    if ($response->is_success) {
        my $parsed = $self->parseResponse($response);
        return $parsed;
    }
    else {
        die "Request for $uri failed: " . $response->status_line;
    }
}

=pod

Returns the name of the caller method.
Intended to be used in the user-defined methods.

=cut

sub method {
    return shift->{method};
}

=pod

Returns the original parameters passed to the caller method.
Intended to be used in the user-defined methods.

=cut

sub methodParameters {
    return shift->{methodParameters};
}

sub rest {
    my ($self, %params) = @_;

    my $requestMethod = $params{requestMethod} || 'POST';
    unless ($self->{rest}->{$requestMethod}) {
        my $p = {
        };
        $p->{ua} = LWP::UserAgent->new(agent => USER_AGENT);

          # agent                   "libwww-perl/#.###"
          # from                    undef
          # conn_cache              undef
          # cookie_jar              undef
          # default_headers         HTTP::Headers->new
          # local_address           undef
          # ssl_opts                { verify_hostname => 1 }
          # max_size                undef
          # max_redirect            7
          # parse_head              1
          # protocols_allowed       undef
          # protocols_forbidden     undef
          # requests_redirectable   ['GET', 'HEAD']
          # timeout                 180

        if ($self->{proxy}) {
            $p->{proxy} = $self->{proxy};
        }
        if ($self->{oauth1}) {
            my $oauth = $self->{oauth1};
            $p->{auth} = {
                type => 'oauth',
                oauth_version => '1.0',
                oauth_signature_method => OAUTH1_SIGNATURE_METHOD,
                request_method => $requestMethod,
                base_url => $self->{endpoint},
                # todo validate
                private_key => $oauth->{privateKey},
                oauth_token => $oauth->{token},
                oauth_consumer_key => $oauth->{consumerKey},
            };
        }
        $self->{rest} = FlowPDF::Client::REST->new($p);
    }
    return $self->{rest};
}

sub createRequest {
    my ($self, $method, $uri, $query, $payload, $headers) = @_;

    $uri =~ s{^/+}{};
    my $endpoint = $self->{endpoint};
    $endpoint =~ s{/+$}{};

    my $rest = $self->rest(requestMethod => $method);
    my $url;
    if ($uri) {
        $url = URI->new($endpoint . "/$uri");
    }
    else {
        $url = URI->new($endpoint);
    }

    if ($query) {
        $url->query_form($url->query_form, %$query);
    }

    if ($self->{oauth1}) {
        require FlowPDF::ComponentManager;
        my $oauth = FlowPDF::ComponentManager->getComponent('FlowPDF::Component::OAuth');
        my $requestParams = $oauth->augment_params_with_oauth($method, $url, $query);
        $url = $rest->augmentUrlWithParams($url, $requestParams);
    }
    my $request = $rest->newRequest($method => $url);

    # auth
    if ($self->{basicAuth}) {
        my $auth = $self->{basicAuth};
        my $username = $auth->{userName};
        my $password = $auth->{password};
        $request->authorization_basic($username, $password);
        logDebug("Added basic auth");
    }
    if ($self->{bearerAuth}) {
        my $auth = $self->{bearerAuth};
        my $token = $auth->{token};
        my $prefix = BEARER_PREFIX;
        $request->header("Authorization", "$prefix $token");
        logDebug("Added bearer auth");
    }

    if ($method eq 'POST' || $method eq 'PUT') {
        $request->header('Content-Type' => CONTENT_TYPE);
    }

    if ($headers) {
        for my $headerName (keys %$headers) {
            $request->header($headerName => $headers->{$headerName});
        }
    }

    if ($payload) {
        logDebug("Payload:", $payload);
        my $encoded = $self->encodePayload($payload);
        $request->content($encoded);
    }

    # proxy should be handled somewhere in the rest
    logDebug("Request: ", $request);

    my $augmentMethod = $self->method . 'AugmentRequest';
    if ($self->can($augmentMethod)) {
        $request = $self->$augmentMethod($request);
    }

    return $request;
}

sub cleanEmptyFields {
    my ($self, $payload) = @_;

    for my $key (keys %$payload) {
        unless ($payload->{$key}) {
            delete $payload->{$key};
        }
        if (ref $payload->{$key} eq 'HASH') {
            $payload->{$key} = $self->cleanEmptyFields($payload->{$key});
        }
    }
    return $payload;
}

sub populateFields {
    my ($self, $object, $params) = @_;

    my $render = sub {
        my ($string) = @_;

        no warnings;
        $string =~ s/(\{\{(\w+)\}\})/$params->{$2}/;
        return $string;
    };

    for my $key (keys %$object) {
        my $value = $object->{$key};
        if (ref $value) {
            if (ref $value eq 'HASH') {
                $object->{$key} = $self->populateFields($value, $params);
            }
            elsif (ref $value eq 'ARRAY') {
                for my $row (@$value) {
                    $row = $self->populateFields($row, $params);
                    # todo fix ref
                }
            }
        }
        else {
            $object->{$key} = $render->($value);
        }
    }
    return $object;
}

sub renderOneLineTemplate {
    my ($template, %params) = @_;

    for my $key (keys %params) {
        $template =~ s/\{\{$key\}\}/$params{$key}/g;
    }
    return $template;
}

# Generated code for the endpoint

# Do not change this code

# SourceChangeOrder: in body

# AuditUser: in body

# ScheduleStartDate: in body

# ScheduleStartTime: in body

# ScheduleDuration: in body

# VerificationStartDate: in body

# VerificationStartTime: in body

# VerificationDuration: in body

# BackoutDuration: in body

# Impact: in body

# Risk: in body

# Changetype: in body

# CAB: in body

# RequirePrivilegeAccess: in body

# OutsideSchMaintWindow: in body

# ITSANFRCmpltd: in body

# NFRMPRefNum: in body

# ClarityPrjIdList: in body

# OptionalAttrVals: in body

# ConfigItemsList: in body

# PCRecords: in body

sub copyChangeRequest {
    my ($self, %params) = @_;

    $self->{method} = 'copyChangeRequest';
    $self->{methodParameters} = \%params;

    my $uri = "/copyChg";
    logDebug "URI Template: $uri";
    $uri = renderOneLineTemplate($uri, %params);
    logDebug "Rendered URI: $uri";

    my $query = {

    };

    logDebug "Query", $query;

    # TODO handle credentials
    # TODO Handle empty parameters
    my $payload = {

        'SourceChangeOrder' => $params{ 'SourceChangeOrder' },

        'AuditUser' => $params{ 'AuditUser' },

        'ScheduleStartDate' => $params{ 'ScheduleStartDate' },

        'ScheduleStartTime' => $params{ 'ScheduleStartTime' },

        'ScheduleDuration' => $params{ 'ScheduleDuration' },

        'VerificationStartDate' => $params{ 'VerificationStartDate' },

        'VerificationStartTime' => $params{ 'VerificationStartTime' },

        'VerificationDuration' => $params{ 'VerificationDuration' },

        'BackoutDuration' => $params{ 'BackoutDuration' },

        'Impact' => $params{ 'Impact' },

        'Risk' => $params{ 'Risk' },

        'Changetype' => $params{ 'Changetype' },

        'CAB' => $params{ 'CAB' },

        'RequirePrivilegeAccess' => $params{ 'RequirePrivilegeAccess' },

        'OutsideSchMaintWindow' => $params{ 'OutsideSchMaintWindow' },

        'ITSANFRCmpltd' => $params{ 'ITSANFRCmpltd' },

        'NFRMPRefNum' => $params{ 'NFRMPRefNum' },

        'ClarityPrjIdList' => $params{ 'ClarityPrjIdList' },

        'OptionalAttrVals' => $params{ 'OptionalAttrVals' },

        'ConfigItemsList' => $params{ 'ConfigItemsList' },

        'PCRecords' => $params{ 'PCRecords' },

    };
    logDebug($payload);

    $payload = $self->cleanEmptyFields($payload);

    my $headers = {
        'Accept' => renderOneLineTemplate('application/xml', %params),
    };

    $headers->{'Content-Type'} = 'application/xml';

    # Creating a request object
    my $response = $self->makeRequest('POST', $uri, $query, $payload, $headers, \%params);
    return $response;
}

# Generated code for the endpoint

# Do not change this code

# referenceNumber: in body

# SubmittedForApprovalBy: in body

sub submitForApprovalChangeRequest {
    my ($self, %params) = @_;

    $self->{method} = 'submitForApprovalChangeRequest';
    $self->{methodParameters} = \%params;

    my $uri = "/subForAppChg";
    logDebug "URI Template: $uri";
    $uri = renderOneLineTemplate($uri, %params);
    logDebug "Rendered URI: $uri";

    my $query = {

    };

    logDebug "Query", $query;

    # TODO handle credentials
    # TODO Handle empty parameters
    my $payload = {

        'referenceNumber' => $params{ 'referenceNumber' },

        'SubmittedForApprovalBy' => $params{ 'SubmittedForApprovalBy' },

    };
    logDebug($payload);

    $payload = $self->cleanEmptyFields($payload);

    my $headers = {
        'Accept' => renderOneLineTemplate('application/xml', %params),
    };

    $headers->{'Content-Type'} = 'application/xml';

    # Creating a request object
    my $response = $self->makeRequest('POST', $uri, $query, $payload, $headers, \%params);
    return $response;
}

# Generated code for the endpoint

# Do not change this code

# ReferenceNumber: in body

# Approvedby: in body

# ApproverGroup: in body

# ApprovalStatus: in body

# Comment: in body

# CABReview: in body

sub approveChangeRequest {
    my ($self, %params) = @_;

    $self->{method} = 'approveChangeRequest';
    $self->{methodParameters} = \%params;

    my $uri = "/approveChg";
    logDebug "URI Template: $uri";
    $uri = renderOneLineTemplate($uri, %params);
    logDebug "Rendered URI: $uri";

    my $query = {

    };

    logDebug "Query", $query;

    # TODO handle credentials
    # TODO Handle empty parameters
    my $payload = {

        'ReferenceNumber' => $params{ 'ReferenceNumber' },

        'Approvedby' => $params{ 'Approvedby' },

        'ApproverGroup' => $params{ 'ApproverGroup' },

        'ApprovalStatus' => $params{ 'ApprovalStatus' },

        'Comment' => $params{ 'Comment' },

        'CABReview' => $params{ 'CABReview' },

    };
    logDebug($payload);

    $payload = $self->cleanEmptyFields($payload);

    my $headers = {
        'Accept' => renderOneLineTemplate('application/xml', %params),
    };

    $headers->{'Content-Type'} = 'application/xml';

    # Creating a request object
    my $response = $self->makeRequest('POST', $uri, $query, $payload, $headers, \%params);
    return $response;
}
## DO NOT EDIT THIS BLOCK === rest client ends, checksum: 1660102e3b7906335c22bcd591983510 ===
sub getServiceAccountToken {
    my ($self, $tokenURL, $serviceAccount, $serviceAccountPass) = @_;

    my $url = URI->new($tokenURL);
    my %data = ( "username" => $serviceAccount,
        "password" => $serviceAccountPass,
        "grant_type" => "password",
        "client_id" => "gsd-client",
        "client_secret" => "gsd-secret" );
    my $ua = LWP::UserAgent->new();
    my $request = HTTP::Request::Common::POST( $url, [ %data ] );
    logDebug("token Response", $request);
    my $response = $ua->request($request);
    logDebug("token Response", $response);
    if ($response->is_success) {
        my $json = decode_json($response->content);
        return $json->{'access_token'};
    }
    else {
        die "Request for $url failed: " . $response->status_line;
    }
}

sub convertDateToSecond {
    my ($self, $str) =  @_;
    my $dt = DateTime::Format::ISO8601->parse_datetime( $str );
    return $dt->epoch;
}

sub copyChangeRequest {
    my ($self, %params) = @_;

    my $authToken = $self->getServiceAccountToken($params{ 'authTokenURL' },
                        $params{ 'serviceAccountName' }, $self->{bearerAuth}->{token});
    $params{ 'authToken' }  = $authToken;

    $self->{method} = 'copyChangeRequest';
    $self->{methodParameters} = \%params;

    my $uri = "/copyChg";
    logDebug "URI Template: $uri";
    $uri = renderOneLineTemplate($uri, %params);
    logDebug "Rendered URI: $uri";

    my $query = {

    };

    logDebug "Query", $query;

    # TODO handle credentials
    # TODO Handle empty parameters

    #CopyChangeOrderRequestDetail
    my %CopyChangeOrderRequestDetail;
    tie %CopyChangeOrderRequestDetail, 'Tie::IxHash';
    %CopyChangeOrderRequestDetail = (
        'SourceChangeOrder' => [$params{ 'SourceChangeOrder' }],
        'AuditUser' => [$params{ 'AuditUser' }],
        'ScheduleStartDate' => [$self->convertDateToSecond($params{ 'ScheduleStartDate' } . "T" . $params{ 'ScheduleStartTime' })],
        'ScheduleDuration' => [$params{ 'ScheduleDuration' }],
        'VerificationStartDate' => [$self->convertDateToSecond($params{ 'VerificationStartDate' } . "T" . $params{ 'VerificationStartTime' })],
        'VerificationDuration' => [$params{ 'VerificationDuration' }],
        'BackoutDuration' => [$params{ 'BackoutDuration' }],
        'Impact' => [$params{ 'Impact' }],
        'Risk' => [$params{ 'Risk' }],
        'Changetype' => [$params{ 'Changetype' }],
        'CAB' => [$params{ 'CAB' }],
        'RequirePrivilegeAccess' => [$params{ 'RequirePrivilegeAccess' } eq 'true' ? 'Yes':'No'],
        'OutsideSchMaintWindow' => [$params{ 'OutsideSchMaintWindow' } eq 'true' ? 'Yes':'No'],
        'ITSANFRCmpltd' => [$params{ 'ITSANFRCmpltd' } eq 'true' ? 'Yes':'No'],
        'NFRMPRefNum' => [$params{ 'NFRMPRefNum' }],
        'ClarityPrjIdList' => [$params{ 'ClarityPrjIdList' }],
        'OptionalAttrVals' => [$params{ 'OptionalAttrVals' }],
        'ConfigItemsList' => [$params{ 'ConfigItemsList' }],
        'PCRecords' => [$params{ 'PCRecords' }],
    );

    my %CopyChangeOrderRequest;
    tie %CopyChangeOrderRequest, 'Tie::IxHash';
    %CopyChangeOrderRequest = (
        'xmlns' => 'http://www.hsbc.com/gsd/rest/CopyChangeOrderRequest_v3.0.xsd',
        'version' => '3.0',
        'genDateTZ' => '12345',
        'function' => 'CopyChangeOrder',
        'action' => 'Create',
        'ApplicationID' => [$params{ 'serviceAccountName' }],
        'CopyChangeOrderRequestDetail' => [\%CopyChangeOrderRequestDetail]
    );

    my $payload = {
        'CopyChangeOrderRequest' => \%CopyChangeOrderRequest
    };

    logDebug($payload);
    $payload = $self->cleanEmptyFields($payload);

    my $headers = {
        'Accept' => renderOneLineTemplate('application/xml', %params),
    };

    $headers->{'Content-Type'} = 'application/xml';

    # Creating a request object
    my $response = $self->makeRequest('POST', $uri, $query, $payload, $headers, \%params);
    return $response;
}

sub submitForApprovalChangeRequest {
    my ($self, %params) = @_;

    my $authToken = $self->getServiceAccountToken($params{ 'authTokenURL' },
                        $params{ 'serviceAccountName' }, $self->{bearerAuth}->{token});
    $params{ 'authToken' }  = $authToken;

    $self->{method} = 'submitForApprovalChangeRequest';
    $self->{methodParameters} = \%params;

    my $uri = "/subForAppChg";
    logDebug "URI Template: $uri";
    $uri = renderOneLineTemplate($uri, %params);
    logDebug "Rendered URI: $uri";

    my $query = {

    };

    logDebug "Query", $query;

    # TODO handle credentials
    # TODO Handle empty parameters
    my %SubmitForApprovalChangeRequestDetail;
    tie %SubmitForApprovalChangeRequestDetail, 'Tie::IxHash';
    %SubmitForApprovalChangeRequestDetail = (
        'ReferenceNumber' => [$params{ 'referenceNumber' }],
        'SubmittedForApprovalBy' => [$params{ 'SubmittedForApprovalBy' }],
    );

    my %SubmitForApprovalRequest;
    tie %SubmitForApprovalRequest, 'Tie::IxHash';
    %SubmitForApprovalRequest = (
        'action' => 'ChangeStatusRequest',
        'function' => 'SubmitForApproval',
        'genDateTZ' => '12345',
        'version' => '1.0',
        'xmlns' => 'http://www.hsbc.com/gsd/rest/SubmitForApprovalRequest_v1.0.xsd',

        'ApplicationID' => [$params{ 'serviceAccountName' }],
        'SubmitForApprovalRequestDetail' => [\%SubmitForApprovalChangeRequestDetail]
    );

    my $payload = {
        'SubmitForApprovalRequest' => \%SubmitForApprovalRequest
    };

    logDebug($payload);

    $payload = $self->cleanEmptyFields($payload);

    my $headers = {
        'Accept' => renderOneLineTemplate('application/xml', %params),
    };

    $headers->{'Content-Type'} = 'application/xml';

    # Creating a request object
    my $response = $self->makeRequest('POST', $uri, $query, $payload, $headers, \%params);
    return $response;
}

sub approveChangeRequest {
    my ($self, %params) = @_;

    my $authToken = $self->getServiceAccountToken($params{ 'authTokenURL' },
                        $params{ 'serviceAccountName' }, $self->{bearerAuth}->{token});
    $params{ 'authToken' }  = $authToken;

    $self->{method} = 'approveChangeRequest';
    $self->{methodParameters} = \%params;

    my $uri = "/approveChg";
    logDebug "URI Template: $uri";
    $uri = renderOneLineTemplate($uri, %params);
    logDebug "Rendered URI: $uri";

    my $query = {

    };

    logDebug "Query", $query;

    # TODO handle credentials
    # TODO Handle empty parameters
    my %ApproveChangeOrderRequestDetail;
    tie %ApproveChangeOrderRequestDetail, 'Tie::IxHash';

    %ApproveChangeOrderRequestDetail = (
        'ReferenceNumber' => [$params{ 'ReferenceNumber' }],
        'Approvedby' => [$params{ 'Approvedby' }],
        'ApproverGroup' => [$params{ 'ApproverGroup' }],
        'ApprovalStatus' => [$params{ 'ApprovalStatus' }],
        'Comment' => [$params{ 'Comment' }],
        'CABReview' => [$params{ 'CABReview' }],
    );

    my %ApproveChangeOrderRequest;
    tie %ApproveChangeOrderRequest, 'Tie::IxHash';
    %ApproveChangeOrderRequest = (
        'xmlns' => 'http://www.hsbc.com/gsd/rest/ApproveChangeOrderRequest_v1.0.xsd',
        'version' => '1.0',
        'genDateTZ' => '12345',
        'function' => 'ApproveChangeOrder',
        'action' => 'ChangeStatusRequest',
        'ApplicationID' => [$params{ 'serviceAccountName' }],
        'ApproveChangeOrderRequestDetail' => [\%ApproveChangeOrderRequestDetail]
    );

    my $payload = {
        'ApproveChangeOrderRequest' => \%ApproveChangeOrderRequest
    };

    logDebug($payload);

    $payload = $self->cleanEmptyFields($payload);

    my $headers = {
        'Accept' => renderOneLineTemplate('application/xml', %params),
    };

    $headers->{'Content-Type'} = 'application/xml';

    # Creating a request object
    my $response = $self->makeRequest('POST', $uri, $query, $payload, $headers, \%params);
    return $response;
}

=pod

Use this method to change HTTP::Request object before the request, e.g.

    $r->header('Authorization', $myCustomAuthHeader);

If you are using custom authorization, it can be placed in here. Call $self->method to find out the wrapper
method name.

    $r HTTP::Request object to augment
    $params Original parameters passed to the wrapper method.

The returned HTTP::Request object will be sent to the API server.

Examples:

    if ($self->method eq 'uploadFile') {
        return $self->_handleUploadLogic($params);
    }

    my $method = $self->method;
    my $augmentMethod = $method . 'Augment';
    if ($self->can($augmentMethod)) {
        return $self->$augmentMethod($r, $params);
    }

=cut

sub augmentRequest {
    my ($self, $r, $params) = @_;
    # empty, for user to fill
    #$r->header(':gsd_access_token', $self->{bearerAuth}->{token});
    $r->header(':gsd_access_token', $params->{'authToken'});

    return $r;
}

=pod

Use this method to override default payload encoding.
By default the payload is encoded as JSON.

=cut

sub encodePayload {
    my ($self, $payload) = @_;

    #return encode_json($payload);
    #GSD does not support json, so we have to provide XML instead

    return XMLout($payload,  KeepRoot => 1, NoSort => 1, NoEscape => 1);
}

=pod

Use this method to change process response logic.

$response HTTP::Response object.

If this method returns a value, this value will be returned from the caller method.

Examples:

    unless ($response->is_success) {
        my $json = decode_json($response->content);
        my $errorMessage = $json->{errorMessage};
        die "Response failed: $errorMessage";
    }

    unless($response->is_success) {
        if ($self->{retries} < $retries) {
            $self->{retries} ++;
            my $p = $self->methodParameters;
            my $method = $self->method;
            return $self->$method($p);
        }
        else {
            die "Response failed and retries count has been exceeded";
        }
    }

=cut

sub processResponse {
    my ($self, $response) = @_;

    return undef;
}

=pod

Use this method to override default response decoding logic.
By default the response is decoded as JSON.

$response HTTP::Response object.

The method should return deserialized response.

=cut

sub parseResponse {
    my ($self, $response) = @_;

    if ($response->content) {
        return XMLin($response->content);
    }
}

1;