package FlowPlugin::CAGlobalServiceDesk;
use JSON;
use strict;
use warnings;
use base qw/FlowPDF/;
use FlowPDF::Log;
use Data::Dumper;
use FlowPDF::Helpers qw/bailOut/;

# Feel free to use new libraries here, e.g. use File::Temp;

# Service function that is being used to set some metadata for a plugin.
sub pluginInfo {
    return {
        pluginName          => '@PLUGIN_KEY@',
        pluginVersion       => '@PLUGIN_VERSION@',
        configFields        => ['config'],
        configLocations     => ['ec_plugin_cfgs'],
        defaultConfigValues => {}
    };
}

# Auto-generated method for the procedure Copy Change Request/Copy Change Request
# Add your code into this method and it will be called when step runs
# Parameter: config
# Parameter: SourceChangeOrder
# Parameter: AuditUser
# Parameter: ScheduleStartDate
# Parameter: ScheduleStartTime
# Parameter: ScheduleDuration
# Parameter: VerificationStartDate
# Parameter: VerificationStartTime
# Parameter: VerificationDuration
# Parameter: BackoutDuration
# Parameter: Impact
# Parameter: Risk
# Parameter: Changetype
# Parameter: CAB
# Parameter: RequirePrivilegeAccess
# Parameter: OutsideSchMaintWindow
# Parameter: ITSANFRCmpltd
# Parameter: NFRMPRefNum
# Parameter: ClarityPrjIdList
# Parameter: OptionalAttrVals
# Parameter: ConfigItemsList
# Parameter: PCRecords

sub copyChangeRequest {
    my ($pluginObject) = @_;

    my $context = $pluginObject->getContext();
    my $params = $context->getRuntimeParameters();
    
    my $ECCAGlobalServiceDeskRESTClient = $pluginObject->getECCAGlobalServiceDeskRESTClient;
    # If you have changed your parameters in the procedure declaration, add/remove them here
    my %restParams = (
        'serviceAccountName' => $params->{'serviceAccountName'},
        'authTokenURL' => $params->{'authTokenURL'},        
        'SourceChangeOrder' => $params->{'SourceChangeOrder'},
        'AuditUser' => $params->{'AuditUser'},
        'ScheduleStartDate' => $params->{'ScheduleStartDate'},
        'ScheduleStartTime' => $params->{'ScheduleStartTime'},
        'ScheduleDuration' => $params->{'ScheduleDuration'},
        'VerificationStartDate' => $params->{'VerificationStartDate'},
        'VerificationStartTime' => $params->{'VerificationStartTime'},
        'VerificationDuration' => $params->{'VerificationDuration'},
        'BackoutDuration' => $params->{'BackoutDuration'},
        'Impact' => $params->{'Impact'},
        'Risk' => $params->{'Risk'},
        'Changetype' => $params->{'Changetype'},
        'CAB' => $params->{'CAB'},
        'RequirePrivilegeAccess' => $params->{'RequirePrivilegeAccess'},
        'OutsideSchMaintWindow' => $params->{'OutsideSchMaintWindow'},
        'ITSANFRCmpltd' => $params->{'ITSANFRCmpltd'},
        'NFRMPRefNum' => $params->{'NFRMPRefNum'},
        'ClarityPrjIdList' => $params->{'ClarityPrjIdList'},
        'OptionalAttrVals' => $params->{'OptionalAttrVals'},
        'ConfigItemsList' => $params->{'ConfigItemsList'},
        'PCRecords' => $params->{'PCRecords'},
    );
    my $response = $ECCAGlobalServiceDeskRESTClient->copyChangeRequest(%restParams);
    logInfo("Got response from the server: ", $response);
    
    my $stepResult = $context->newStepResult;

    if( $response->{'CopyChangeOrderResponseDetail'}->{'Rc'} != 0 ) {
        bailOut $response->{'CopyChangeOrderResponseDetail'}->{'ReplyText'};
    }
    
    $stepResult->setOutputParameter(referenceNumber => $response->{'CopyChangeOrderResponseDetail'}->{'ReferenceNumber'});
    $stepResult->setOutputParameter(restResult => encode_json($response->{'CopyChangeOrderResponseDetail'}));
    
    $stepResult->apply();
}

# This method is used to access auto-generated REST client.
sub getECCAGlobalServiceDeskRESTClient {
    my ($self) = @_;

    my $context = $self->getContext();
    my $config = $context->getRuntimeParameters();
    require FlowPlugin::ECCAGlobalServiceDeskRESTClient;
    my $client = FlowPlugin::ECCAGlobalServiceDeskRESTClient->createFromConfig($config);
    return $client;
}
# Auto-generated method for the procedure Submit for Approval Change Request/Submit for Approval Change Request
# Add your code into this method and it will be called when step runs
# Parameter: config
# Parameter: referenceNumber
# Parameter: SubmittedForApprovalBy

sub submitForApprovalChangeRequest {
    my ($pluginObject) = @_;

    my $context = $pluginObject->getContext();
    my $params = $context->getRuntimeParameters();

    my $ECCAGlobalServiceDeskRESTClient = $pluginObject->getECCAGlobalServiceDeskRESTClient;
    # If you have changed your parameters in the procedure declaration, add/remove them here
    my %restParams = (
        'serviceAccountName' => $params->{'serviceAccountName'},
        'authTokenURL' => $params->{'authTokenURL'}, 
        'referenceNumber' => $params->{'referenceNumber'},
        'SubmittedForApprovalBy' => $params->{'SubmittedForApprovalBy'},
    );
    my $response = $ECCAGlobalServiceDeskRESTClient->submitForApprovalChangeRequest(%restParams);
    logInfo("Got response from the server: ", $response);

    my $stepResult = $context->newStepResult;
    $stepResult->setOutputParameter('restResult', encode_json($response));

    if( $response->{'SubmitForApprovalResponseDetail'}->{'Rc'} != 0 ) {
        bailOut $response->{'SubmitForApprovalResponseDetail'}->{'ReplyText'};
    }
    
    $stepResult->setOutputParameter(restResult => encode_json($response->{'SubmitForApprovalResponseDetail'}));
    
    $stepResult->apply();
}

# Auto-generated method for the procedure Approve Change Order Request/Approve Change Order Request
# Add your code into this method and it will be called when step runs
# Parameter: config
# Parameter: ReferenceNumber
# Parameter: Approvedby
# Parameter: ApproverGroup
# Parameter: ApprovalStatus
# Parameter: Comment
# Parameter: CABReview

sub approveChangeOrderRequest {
    my ($pluginObject) = @_;

    my $context = $pluginObject->getContext();
    my $params = $context->getRuntimeParameters();

    my $ECCAGlobalServiceDeskRESTClient = $pluginObject->getECCAGlobalServiceDeskRESTClient;
    # If you have changed your parameters in the procedure declaration, add/remove them here
    my %restParams = (
        'serviceAccountName' => $params->{'serviceAccountName'},
        'authTokenURL' => $params->{'authTokenURL'}, 
        'ReferenceNumber' => $params->{'ReferenceNumber'},
        'Approvedby' => $params->{'Approvedby'},
        'ApproverGroup' => $params->{'ApproverGroup'},
        'ApprovalStatus' => $params->{'ApprovalStatus'},
        'Comment' => $params->{'Comment'},
        'CABReview' => $params->{'CABReview'},
    );
    my $response = $ECCAGlobalServiceDeskRESTClient->approveChangeRequest(%restParams);
    logInfo("Got response from the server: ", $response);

    my $stepResult = $context->newStepResult;
    $stepResult->setOutputParameter('restResult', encode_json($response));

    if( $response->{'ApproveChangeOrderResponseDetail'}->{'Rc'} != 0 ) {
        bailOut $response->{'ApproveChangeOrderResponseDetail'}->{'ReplyText'};
    }

    $stepResult->apply();
}

## === step ends ===
# Please do not remove the marker above, it is used to place new procedures into this file.


1;