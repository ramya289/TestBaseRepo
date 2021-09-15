public class MetadataService {

    public static String SOAP_M_URI = 'http://soap.sforce.com/2006/04/metadata';

    public class CustomMetadata extends Metadata {
        public String type = 'CustomMetadata';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public String label;
        public Boolean protected_x;
        public MetadataService.CustomMetadataValue[] values;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] protected_x_type_info = new String[]{'protected',SOAP_M_URI,null,'0','1','false'};
        private String[] values_type_info = new String[]{'values',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','label','protected_x','values'};
    }
    public class CustomMetadataValue {
        public String field;
        public String value;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field','value'};
    }

    public class SaveResult {
        public MetadataService.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'errors','fullName','success'};
    }
    
    public class readMetadataResponse_element {
        public MetadataService.ReadResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class MiniLayout {
        public String[] fields;
        public MetadataService.RelatedListItem[] relatedLists;
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] relatedLists_type_info = new String[]{'relatedLists',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fields','relatedLists'};
    }
    public class FieldValue {
        public String name;
        public String value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','value'};
    }
    
    public class UpsertResult {
        public Boolean created;
        public MetadataService.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] created_type_info = new String[]{'created',SOAP_M_URI,null,'1','1','false'};
        private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'created','errors','fullName','success'};
    }
    
    public class DeleteResult {
        public MetadataService.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'errors','fullName','success'};
    }

    public class SearchLayouts {
        public String[] customTabListAdditionalFields;
        public String[] excludedStandardButtons;
        public String[] listViewButtons;
        public String[] lookupDialogsAdditionalFields;
        public String[] lookupFilterFields;
        public String[] lookupPhoneDialogsAdditionalFields;
        public String[] searchFilterFields;
        public String[] searchResultsAdditionalFields;
        public String[] searchResultsCustomButtons;
        private String[] customTabListAdditionalFields_type_info = new String[]{'customTabListAdditionalFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] excludedStandardButtons_type_info = new String[]{'excludedStandardButtons',SOAP_M_URI,null,'0','-1','false'};
        private String[] listViewButtons_type_info = new String[]{'listViewButtons',SOAP_M_URI,null,'0','-1','false'};
        private String[] lookupDialogsAdditionalFields_type_info = new String[]{'lookupDialogsAdditionalFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] lookupFilterFields_type_info = new String[]{'lookupFilterFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] lookupPhoneDialogsAdditionalFields_type_info = new String[]{'lookupPhoneDialogsAdditionalFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] searchFilterFields_type_info = new String[]{'searchFilterFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] searchResultsAdditionalFields_type_info = new String[]{'searchResultsAdditionalFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] searchResultsCustomButtons_type_info = new String[]{'searchResultsCustomButtons',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'customTabListAdditionalFields','excludedStandardButtons','listViewButtons','lookupDialogsAdditionalFields','lookupFilterFields','lookupPhoneDialogsAdditionalFields','searchFilterFields','searchResultsAdditionalFields','searchResultsCustomButtons'};
    }
    
    
    public class PackageTypeMembers {
        public String[] members;
        public String name;
        private String[] members_type_info = new String[]{'members',SOAP_M_URI,null,'0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'members','name'};
    }
    
    public class RelatedListItem {
        public String[] customButtons;
        public String[] excludeButtons;
        public String[] fields;
        public String relatedList;
        public String sortField;
        public String sortOrder;
        private String[] customButtons_type_info = new String[]{'customButtons',SOAP_M_URI,null,'0','-1','false'};
        private String[] excludeButtons_type_info = new String[]{'excludeButtons',SOAP_M_URI,null,'0','-1','false'};
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] relatedList_type_info = new String[]{'relatedList',SOAP_M_URI,null,'1','1','false'};
        private String[] sortField_type_info = new String[]{'sortField',SOAP_M_URI,null,'0','1','false'};
        private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'customButtons','excludeButtons','fields','relatedList','sortField','sortOrder'};
    }
    
    public class PackageVersion {
        public Integer majorNumber;
        public Integer minorNumber;
        public String namespace;
        private String[] majorNumber_type_info = new String[]{'majorNumber',SOAP_M_URI,null,'1','1','false'};
        private String[] minorNumber_type_info = new String[]{'minorNumber',SOAP_M_URI,null,'1','1','false'};
        private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'majorNumber','minorNumber','namespace'};
    }
    public class DescribeMetadataObject {
        public String[] childXmlNames;
        public String directoryName;
        public Boolean inFolder;
        public Boolean metaFile;
        public String suffix;
        public String xmlName;
        private String[] childXmlNames_type_info = new String[]{'childXmlNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] directoryName_type_info = new String[]{'directoryName',SOAP_M_URI,null,'1','1','false'};
        private String[] inFolder_type_info = new String[]{'inFolder',SOAP_M_URI,null,'1','1','false'};
        private String[] metaFile_type_info = new String[]{'metaFile',SOAP_M_URI,null,'1','1','false'};
        private String[] suffix_type_info = new String[]{'suffix',SOAP_M_URI,null,'0','1','false'};
        private String[] xmlName_type_info = new String[]{'xmlName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'childXmlNames','directoryName','inFolder','metaFile','suffix','xmlName'};
    }
    
    public class AllOrNoneHeader_element {
        public Boolean allOrNone;
        private String[] allOrNone_type_info = new String[]{'allOrNone',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allOrNone'};
    }
    
    public class listMetadata_element {
        public MetadataService.ListMetadataQuery[] queries;
        public Double asOfVersion;
        private String[] queries_type_info = new String[]{'queries',SOAP_M_URI,null,'0','-1','false'};
        private String[] asOfVersion_type_info = new String[]{'asOfVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'queries','asOfVersion'};
    }
    
    public class HomePageLayout extends Metadata {
        public String type = 'HomePageLayout';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String[] narrowComponents;
        public String[] wideComponents;
        private String[] narrowComponents_type_info = new String[]{'narrowComponents',SOAP_M_URI,null,'0','-1','false'};
        private String[] wideComponents_type_info = new String[]{'wideComponents',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'narrowComponents','wideComponents'};
    }
    
    public class Layout extends Metadata {
        public String type = 'Layout';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String[] customButtons;
        public MetadataService.CustomConsoleComponents customConsoleComponents;
        public Boolean emailDefault;
        public String[] excludeButtons;
        public MetadataService.FeedLayout feedLayout;
        public String[] headers;
        public MetadataService.LayoutSection[] layoutSections;
        public MetadataService.MiniLayout miniLayout;
        public String[] multilineLayoutFields;
        public MetadataService.PlatformActionList platformActionList;
        public MetadataService.QuickActionList quickActionList;
        public MetadataService.RelatedContent relatedContent;
        public MetadataService.RelatedListItem[] relatedLists;
        public String[] relatedObjects;
        public Boolean runAssignmentRulesDefault;
        public Boolean showEmailCheckbox;
        public Boolean showHighlightsPanel;
        public Boolean showInteractionLogPanel;
        public Boolean showKnowledgeComponent;
        public Boolean showRunAssignmentRulesCheckbox;
        public Boolean showSolutionSection;
        public Boolean showSubmitAndAttachButton;
        public MetadataService.SummaryLayout summaryLayout;
        private String[] customButtons_type_info = new String[]{'customButtons',SOAP_M_URI,null,'0','-1','false'};
        private String[] customConsoleComponents_type_info = new String[]{'customConsoleComponents',SOAP_M_URI,null,'0','1','false'};
        private String[] emailDefault_type_info = new String[]{'emailDefault',SOAP_M_URI,null,'0','1','false'};
        private String[] excludeButtons_type_info = new String[]{'excludeButtons',SOAP_M_URI,null,'0','-1','false'};
        private String[] feedLayout_type_info = new String[]{'feedLayout',SOAP_M_URI,null,'0','1','false'};
        private String[] headers_type_info = new String[]{'headers',SOAP_M_URI,null,'0','-1','false'};
        private String[] layoutSections_type_info = new String[]{'layoutSections',SOAP_M_URI,null,'0','-1','false'};
        private String[] miniLayout_type_info = new String[]{'miniLayout',SOAP_M_URI,null,'0','1','false'};
        private String[] multilineLayoutFields_type_info = new String[]{'multilineLayoutFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] platformActionList_type_info = new String[]{'platformActionList',SOAP_M_URI,null,'0','1','false'};
        private String[] quickActionList_type_info = new String[]{'quickActionList',SOAP_M_URI,null,'0','1','false'};
        private String[] relatedContent_type_info = new String[]{'relatedContent',SOAP_M_URI,null,'0','1','false'};
        private String[] relatedLists_type_info = new String[]{'relatedLists',SOAP_M_URI,null,'0','-1','false'};
        private String[] relatedObjects_type_info = new String[]{'relatedObjects',SOAP_M_URI,null,'0','-1','false'};
        private String[] runAssignmentRulesDefault_type_info = new String[]{'runAssignmentRulesDefault',SOAP_M_URI,null,'0','1','false'};
        private String[] showEmailCheckbox_type_info = new String[]{'showEmailCheckbox',SOAP_M_URI,null,'0','1','false'};
        private String[] showHighlightsPanel_type_info = new String[]{'showHighlightsPanel',SOAP_M_URI,null,'0','1','false'};
        private String[] showInteractionLogPanel_type_info = new String[]{'showInteractionLogPanel',SOAP_M_URI,null,'0','1','false'};
        private String[] showKnowledgeComponent_type_info = new String[]{'showKnowledgeComponent',SOAP_M_URI,null,'0','1','false'};
        private String[] showRunAssignmentRulesCheckbox_type_info = new String[]{'showRunAssignmentRulesCheckbox',SOAP_M_URI,null,'0','1','false'};
        private String[] showSolutionSection_type_info = new String[]{'showSolutionSection',SOAP_M_URI,null,'0','1','false'};
        private String[] showSubmitAndAttachButton_type_info = new String[]{'showSubmitAndAttachButton',SOAP_M_URI,null,'0','1','false'};
        private String[] summaryLayout_type_info = new String[]{'summaryLayout',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'customButtons','customConsoleComponents','emailDefault','excludeButtons','feedLayout','headers','layoutSections','miniLayout','multilineLayoutFields','platformActionList','quickActionList','relatedContent','relatedLists','relatedObjects','runAssignmentRulesDefault','showEmailCheckbox','showHighlightsPanel','showInteractionLogPanel','showKnowledgeComponent','showRunAssignmentRulesCheckbox','showSolutionSection','showSubmitAndAttachButton','summaryLayout'};
    }
    
    public class FieldOverride {
        public String field;
        public String formula;
        public String literalValue;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] formula_type_info = new String[]{'formula',SOAP_M_URI,null,'0','1','false'};
        private String[] literalValue_type_info = new String[]{'literalValue',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field','formula','literalValue'};
    }
        
    public class QuickAction extends Metadata {
        public String type = 'QuickAction';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String canvas;
        public String description;
        public MetadataService.FieldOverride[] fieldOverrides;
        public Integer height;
        public String icon;
        public Boolean isProtected;
        public String label;
        public String page_x;
        public MetadataService.QuickActionLayout quickActionLayout;
        public String standardLabel;
        public String targetObject;
        public String targetParentField;
        public String targetRecordType;
        public String type_x;
        public Integer width;
        private String[] canvas_type_info = new String[]{'canvas',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] fieldOverrides_type_info = new String[]{'fieldOverrides',SOAP_M_URI,null,'0','-1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] icon_type_info = new String[]{'icon',SOAP_M_URI,null,'0','1','false'};
        private String[] isProtected_type_info = new String[]{'isProtected',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] quickActionLayout_type_info = new String[]{'quickActionLayout',SOAP_M_URI,null,'0','1','false'};
        private String[] standardLabel_type_info = new String[]{'standardLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] targetObject_type_info = new String[]{'targetObject',SOAP_M_URI,null,'0','1','false'};
        private String[] targetParentField_type_info = new String[]{'targetParentField',SOAP_M_URI,null,'0','1','false'};
        private String[] targetRecordType_type_info = new String[]{'targetRecordType',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'canvas','description','fieldOverrides','height','icon','isProtected','label','page_x','quickActionLayout','standardLabel','targetObject','targetParentField','targetRecordType','type_x','width'};
    }
   
    public class ChannelLayoutItem {
        public String field;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field'};
    }

    public class SharedTo {
        public String allCustomerPortalUsers;
        public String allInternalUsers;
        public String allPartnerUsers;
        public String[] group_x;
        public String[] groups;
        public String[] managerSubordinates;
        public String[] managers;
        public String[] portalRole;
        public String[] portalRoleAndSubordinates;
        public String[] queue;
        public String[] role;
        public String[] roleAndSubordinates;
        public String[] roleAndSubordinatesInternal;
        public String[] roles;
        public String[] rolesAndSubordinates;
        public String[] territories;
        public String[] territoriesAndSubordinates;
        public String[] territory;
        public String[] territoryAndSubordinates;
        private String[] allCustomerPortalUsers_type_info = new String[]{'allCustomerPortalUsers',SOAP_M_URI,null,'0','1','false'};
        private String[] allInternalUsers_type_info = new String[]{'allInternalUsers',SOAP_M_URI,null,'0','1','false'};
        private String[] allPartnerUsers_type_info = new String[]{'allPartnerUsers',SOAP_M_URI,null,'0','1','false'};
        private String[] group_x_type_info = new String[]{'group',SOAP_M_URI,null,'0','-1','false'};
        private String[] groups_type_info = new String[]{'groups',SOAP_M_URI,null,'0','-1','false'};
        private String[] managerSubordinates_type_info = new String[]{'managerSubordinates',SOAP_M_URI,null,'0','-1','false'};
        private String[] managers_type_info = new String[]{'managers',SOAP_M_URI,null,'0','-1','false'};
        private String[] portalRole_type_info = new String[]{'portalRole',SOAP_M_URI,null,'0','-1','false'};
        private String[] portalRoleAndSubordinates_type_info = new String[]{'portalRoleAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
        private String[] queue_type_info = new String[]{'queue',SOAP_M_URI,null,'0','-1','false'};
        private String[] role_type_info = new String[]{'role',SOAP_M_URI,null,'0','-1','false'};
        private String[] roleAndSubordinates_type_info = new String[]{'roleAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
        private String[] roleAndSubordinatesInternal_type_info = new String[]{'roleAndSubordinatesInternal',SOAP_M_URI,null,'0','-1','false'};
        private String[] roles_type_info = new String[]{'roles',SOAP_M_URI,null,'0','-1','false'};
        private String[] rolesAndSubordinates_type_info = new String[]{'rolesAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
        private String[] territories_type_info = new String[]{'territories',SOAP_M_URI,null,'0','-1','false'};
        private String[] territoriesAndSubordinates_type_info = new String[]{'territoriesAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
        private String[] territory_type_info = new String[]{'territory',SOAP_M_URI,null,'0','-1','false'};
        private String[] territoryAndSubordinates_type_info = new String[]{'territoryAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allCustomerPortalUsers','allInternalUsers','allPartnerUsers','group_x','groups','managerSubordinates','managers','portalRole','portalRoleAndSubordinates','queue','role','roleAndSubordinates','roleAndSubordinatesInternal','roles','rolesAndSubordinates','territories','territoriesAndSubordinates','territory','territoryAndSubordinates'};
    }

    public class ListView extends Metadata {
        public String type = 'ListView';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String booleanFilter;
        public String[] columns;
        public String division;
        public String filterScope;
        public MetadataService.ListViewFilter[] filters;
        public String label;
        public String language;
        public String queue;
        public MetadataService.SharedTo sharedTo;
        private String[] booleanFilter_type_info = new String[]{'booleanFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] columns_type_info = new String[]{'columns',SOAP_M_URI,null,'0','-1','false'};
        private String[] division_type_info = new String[]{'division',SOAP_M_URI,null,'0','1','false'};
        private String[] filterScope_type_info = new String[]{'filterScope',SOAP_M_URI,null,'1','1','false'};
        private String[] filters_type_info = new String[]{'filters',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] language_type_info = new String[]{'language',SOAP_M_URI,null,'0','1','false'};
        private String[] queue_type_info = new String[]{'queue',SOAP_M_URI,null,'0','1','false'};
        private String[] sharedTo_type_info = new String[]{'sharedTo',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'booleanFilter','columns','division','filterScope','filters','label','language','queue','sharedTo'};
    }
    
    
    public class FeedLayoutFilter {
        public String feedFilterName;
        public String feedFilterType;
        public String feedItemType;
        private String[] feedFilterName_type_info = new String[]{'feedFilterName',SOAP_M_URI,null,'0','1','false'};
        private String[] feedFilterType_type_info = new String[]{'feedFilterType',SOAP_M_URI,null,'1','1','false'};
        private String[] feedItemType_type_info = new String[]{'feedItemType',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'feedFilterName','feedFilterType','feedItemType'};
    }
    
    
    
    public class FileProperties {
        public String createdById;
        public String createdByName;
        public DateTime createdDate;
        public String fileName;
        public String fullName;
        public String id;
        public String lastModifiedById;
        public String lastModifiedByName;
        public DateTime lastModifiedDate;
        public String manageableState;
        public String namespacePrefix;
        public String type_x;
        private String[] createdById_type_info = new String[]{'createdById',SOAP_M_URI,null,'1','1','false'};
        private String[] createdByName_type_info = new String[]{'createdByName',SOAP_M_URI,null,'1','1','false'};
        private String[] createdDate_type_info = new String[]{'createdDate',SOAP_M_URI,null,'1','1','false'};
        private String[] fileName_type_info = new String[]{'fileName',SOAP_M_URI,null,'1','1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedById_type_info = new String[]{'lastModifiedById',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedByName_type_info = new String[]{'lastModifiedByName',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedDate_type_info = new String[]{'lastModifiedDate',SOAP_M_URI,null,'1','1','false'};
        private String[] manageableState_type_info = new String[]{'manageableState',SOAP_M_URI,null,'0','1','false'};
        private String[] namespacePrefix_type_info = new String[]{'namespacePrefix',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'createdById','createdByName','createdDate','fileName','fullName','id','lastModifiedById','lastModifiedByName','lastModifiedDate','manageableState','namespacePrefix','type_x'};
    }
    
    
    public class FeedItemSettings {
        public Integer characterLimit;
        public Boolean collapseThread;
        public String displayFormat;
        public String feedItemType;
        private String[] characterLimit_type_info = new String[]{'characterLimit',SOAP_M_URI,null,'0','1','false'};
        private String[] collapseThread_type_info = new String[]{'collapseThread',SOAP_M_URI,null,'0','1','false'};
        private String[] displayFormat_type_info = new String[]{'displayFormat',SOAP_M_URI,null,'0','1','false'};
        private String[] feedItemType_type_info = new String[]{'feedItemType',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'characterLimit','collapseThread','displayFormat','feedItemType'};
    }
    
    public class CustomConsoleComponents {
        public MetadataService.PrimaryTabComponents primaryTabComponents;
        public MetadataService.SubtabComponents subtabComponents;
        private String[] primaryTabComponents_type_info = new String[]{'primaryTabComponents',SOAP_M_URI,null,'0','1','false'};
        private String[] subtabComponents_type_info = new String[]{'subtabComponents',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'primaryTabComponents','subtabComponents'};
    }
    public class SubtabComponents {
        public MetadataService.Container[] containers;
        private String[] containers_type_info = new String[]{'containers',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'containers'};
    }
    public class DebuggingInfo_element {
        public String debugLog;
        private String[] debugLog_type_info = new String[]{'debugLog',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'debugLog'};
    }
    
    
    public class RelatedContentItem {
        public MetadataService.LayoutItem layoutItem;
        private String[] layoutItem_type_info = new String[]{'layoutItem',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'layoutItem'};
    }
    
    public class SummaryLayoutItem {
        public String customLink;
        public String field;
        public Integer posX;
        public Integer posY;
        public Integer posZ;
        private String[] customLink_type_info = new String[]{'customLink',SOAP_M_URI,null,'0','1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','1','false'};
        private String[] posX_type_info = new String[]{'posX',SOAP_M_URI,null,'1','1','false'};
        private String[] posY_type_info = new String[]{'posY',SOAP_M_URI,null,'0','1','false'};
        private String[] posZ_type_info = new String[]{'posZ',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'customLink','field','posX','posY','posZ'};
    }
    public class QuickActionLayoutItem {
        public Boolean emptySpace;
        public String field;
        public String uiBehavior;
        private String[] emptySpace_type_info = new String[]{'emptySpace',SOAP_M_URI,null,'0','1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','1','false'};
        private String[] uiBehavior_type_info = new String[]{'uiBehavior',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'emptySpace','field','uiBehavior'};
    }
   
    public class FlexiPage extends Metadata {
        public String type = 'FlexiPage';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public MetadataService.FlexiPageRegion[] flexiPageRegions;
        public String masterLabel;
        public String pageTemplate;
        public String parentFlexiPage;
        public MetadataService.PlatformActionList platformActionlist;
        public MetadataService.QuickActionList quickActionList;
        public String sobjectType;
        public String type_x;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] flexiPageRegions_type_info = new String[]{'flexiPageRegions',SOAP_M_URI,null,'0','-1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] pageTemplate_type_info = new String[]{'pageTemplate',SOAP_M_URI,null,'1','1','false'};
        private String[] parentFlexiPage_type_info = new String[]{'parentFlexiPage',SOAP_M_URI,null,'0','1','false'};
        private String[] platformActionlist_type_info = new String[]{'platformActionlist',SOAP_M_URI,null,'0','1','false'};
        private String[] quickActionList_type_info = new String[]{'quickActionList',SOAP_M_URI,null,'0','1','false'};
        private String[] sobjectType_type_info = new String[]{'sobjectType',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','flexiPageRegions','masterLabel','pageTemplate','parentFlexiPage','platformActionlist','quickActionList','sobjectType','type_x'};
    }
    
    public class PlatformActionList {
        public String actionListContext;
        public MetadataService.PlatformActionListItem[] platformActionListItems;
        public String relatedSourceEntity;
        private String[] actionListContext_type_info = new String[]{'actionListContext',SOAP_M_URI,null,'1','1','false'};
        private String[] platformActionListItems_type_info = new String[]{'platformActionListItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] relatedSourceEntity_type_info = new String[]{'relatedSourceEntity',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'actionListContext','platformActionListItems','relatedSourceEntity'};
    }
    
    public class CustomShortcut {
        public String description;
        public String eventName;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] eventName_type_info = new String[]{'eventName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','eventName'};
    }
    
    public class SessionHeader_element {
        public String sessionId;
        private String[] sessionId_type_info = new String[]{'sessionId',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'sessionId'};
    }
    
    
    
    public class FeedFilterCriterion {
        public String feedItemType;
        public String feedItemVisibility;
        public String relatedSObjectType;
        private String[] feedItemType_type_info = new String[]{'feedItemType',SOAP_M_URI,null,'1','1','false'};
        private String[] feedItemVisibility_type_info = new String[]{'feedItemVisibility',SOAP_M_URI,null,'0','1','false'};
        private String[] relatedSObjectType_type_info = new String[]{'relatedSObjectType',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'feedItemType','feedItemVisibility','relatedSObjectType'};
    }
    
    
    public class FieldSet extends Metadata {
        public String type = 'FieldSet';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.FieldSetItem[] availableFields;
        public String description;
        public MetadataService.FieldSetItem[] displayedFields;
        public String label;
        private String[] availableFields_type_info = new String[]{'availableFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'1','1','false'};
        private String[] displayedFields_type_info = new String[]{'displayedFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'availableFields','description','displayedFields','label'};
    }
    
    public class HomePageComponent extends Metadata {
        public String type = 'HomePageComponent';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String body;
        public Integer height;
        public String[] links;
        public String page_x;
        public String pageComponentType;
        public Boolean showLabel;
        public Boolean showScrollbars;
        public String width;
        private String[] body_type_info = new String[]{'body',SOAP_M_URI,null,'0','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] links_type_info = new String[]{'links',SOAP_M_URI,null,'0','-1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] pageComponentType_type_info = new String[]{'pageComponentType',SOAP_M_URI,null,'1','1','false'};
        private String[] showLabel_type_info = new String[]{'showLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] showScrollbars_type_info = new String[]{'showScrollbars',SOAP_M_URI,null,'0','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'body','height','links','page_x','pageComponentType','showLabel','showScrollbars','width'};
    }
    
   
    
    public class CompactLayout extends Metadata {
        public String type = 'CompactLayout';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String[] fields;
        public String label;
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'fields','label'};
    }
    public class VisualizationType {
        public String description;
        public String developerName;
        public String icon;
        public String masterLabel;
        public String scriptBootstrapMethod;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] developerName_type_info = new String[]{'developerName',SOAP_M_URI,null,'1','1','false'};
        private String[] icon_type_info = new String[]{'icon',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] scriptBootstrapMethod_type_info = new String[]{'scriptBootstrapMethod',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'description','developerName','icon','masterLabel','scriptBootstrapMethod'};
    }
   
    public class RelatedContent {
        public MetadataService.RelatedContentItem[] relatedContentItems;
        private String[] relatedContentItems_type_info = new String[]{'relatedContentItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'relatedContentItems'};
    }
    public class WebLink extends Metadata {
        public String type = 'WebLink';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String availability;
        public String description;
        public String displayType;
        public String encodingKey;
        public Boolean hasMenubar;
        public Boolean hasScrollbars;
        public Boolean hasToolbar;
        public Integer height;
        public Boolean isResizable;
        public String linkType;
        public String masterLabel;
        public String openType;
        public String page_x;
        public String position;
        public Boolean protected_x;
        public Boolean requireRowSelection;
        public String scontrol;
        public Boolean showsLocation;
        public Boolean showsStatus;
        public String url;
        public Integer width;
        private String[] availability_type_info = new String[]{'availability',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] displayType_type_info = new String[]{'displayType',SOAP_M_URI,null,'1','1','false'};
        private String[] encodingKey_type_info = new String[]{'encodingKey',SOAP_M_URI,null,'0','1','false'};
        private String[] hasMenubar_type_info = new String[]{'hasMenubar',SOAP_M_URI,null,'0','1','false'};
        private String[] hasScrollbars_type_info = new String[]{'hasScrollbars',SOAP_M_URI,null,'0','1','false'};
        private String[] hasToolbar_type_info = new String[]{'hasToolbar',SOAP_M_URI,null,'0','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] isResizable_type_info = new String[]{'isResizable',SOAP_M_URI,null,'0','1','false'};
        private String[] linkType_type_info = new String[]{'linkType',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] openType_type_info = new String[]{'openType',SOAP_M_URI,null,'1','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] position_type_info = new String[]{'position',SOAP_M_URI,null,'0','1','false'};
        private String[] protected_x_type_info = new String[]{'protected',SOAP_M_URI,null,'1','1','false'};
        private String[] requireRowSelection_type_info = new String[]{'requireRowSelection',SOAP_M_URI,null,'0','1','false'};
        private String[] scontrol_type_info = new String[]{'scontrol',SOAP_M_URI,null,'0','1','false'};
        private String[] showsLocation_type_info = new String[]{'showsLocation',SOAP_M_URI,null,'0','1','false'};
        private String[] showsStatus_type_info = new String[]{'showsStatus',SOAP_M_URI,null,'0','1','false'};
        private String[] url_type_info = new String[]{'url',SOAP_M_URI,null,'0','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'availability','description','displayType','encodingKey','hasMenubar','hasScrollbars','hasToolbar','height','isResizable','linkType','masterLabel','openType','page_x','position','protected_x','requireRowSelection','scontrol','showsLocation','showsStatus','url','width'};
    }
   
    
    
    public class NameSettings extends Metadata {
        public String type = 'NameSettings';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean enableMiddleName;
        public Boolean enableNameSuffix;
        private String[] enableMiddleName_type_info = new String[]{'enableMiddleName',SOAP_M_URI,null,'0','1','false'};
        private String[] enableNameSuffix_type_info = new String[]{'enableNameSuffix',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'enableMiddleName','enableNameSuffix'};
    }
    
    public class ComponentInstance {
        public MetadataService.ComponentInstanceProperty[] componentInstanceProperties;
        public String componentName;
        private String[] componentInstanceProperties_type_info = new String[]{'componentInstanceProperties',SOAP_M_URI,null,'0','-1','false'};
        private String[] componentName_type_info = new String[]{'componentName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'componentInstanceProperties','componentName'};
    }
    public class LayoutSectionTranslation {
        public String label;
        public String section;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] section_type_info = new String[]{'section',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','section'};
    }
    
    public class upsertMetadataResponse_element {
        public MetadataService.UpsertResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }

    public class deleteMetadataResponse_element {
        public MetadataService.DeleteResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }

    public class ChannelLayout {
        public String[] enabledChannels;
        public String label;
        public MetadataService.ChannelLayoutItem[] layoutItems;
        private String[] enabledChannels_type_info = new String[]{'enabledChannels',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] layoutItems_type_info = new String[]{'layoutItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'enabledChannels','label','layoutItems'};
    }
   
   
    
    public class AppMenuItem {
        public String name;
        public String type_x;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','type_x'};
    }
    public class RecordType extends Metadata {
        public String type = 'RecordType';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean active;
        public String businessProcess;
        public String compactLayoutAssignment;
        public String description;
        public String label;
        public MetadataService.RecordTypePicklistValue[] picklistValues;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] businessProcess_type_info = new String[]{'businessProcess',SOAP_M_URI,null,'0','1','false'};
        private String[] compactLayoutAssignment_type_info = new String[]{'compactLayoutAssignment',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] picklistValues_type_info = new String[]{'picklistValues',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'active','businessProcess','compactLayoutAssignment','description','label','picklistValues'};
    }
    
    public class CustomPageWebLink extends Metadata {
        public String type = 'CustomPageWebLink';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String availability;
        public String description;
        public String displayType;
        public String encodingKey;
        public Boolean hasMenubar;
        public Boolean hasScrollbars;
        public Boolean hasToolbar;
        public Integer height;
        public Boolean isResizable;
        public String linkType;
        public String masterLabel;
        public String openType;
        public String page_x;
        public String position;
        public Boolean protected_x;
        public Boolean requireRowSelection;
        public String scontrol;
        public Boolean showsLocation;
        public Boolean showsStatus;
        public String url;
        public Integer width;
        private String[] availability_type_info = new String[]{'availability',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] displayType_type_info = new String[]{'displayType',SOAP_M_URI,null,'1','1','false'};
        private String[] encodingKey_type_info = new String[]{'encodingKey',SOAP_M_URI,null,'0','1','false'};
        private String[] hasMenubar_type_info = new String[]{'hasMenubar',SOAP_M_URI,null,'0','1','false'};
        private String[] hasScrollbars_type_info = new String[]{'hasScrollbars',SOAP_M_URI,null,'0','1','false'};
        private String[] hasToolbar_type_info = new String[]{'hasToolbar',SOAP_M_URI,null,'0','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] isResizable_type_info = new String[]{'isResizable',SOAP_M_URI,null,'0','1','false'};
        private String[] linkType_type_info = new String[]{'linkType',SOAP_M_URI,null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] openType_type_info = new String[]{'openType',SOAP_M_URI,null,'1','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] position_type_info = new String[]{'position',SOAP_M_URI,null,'0','1','false'};
        private String[] protected_x_type_info = new String[]{'protected',SOAP_M_URI,null,'1','1','false'};
        private String[] requireRowSelection_type_info = new String[]{'requireRowSelection',SOAP_M_URI,null,'0','1','false'};
        private String[] scontrol_type_info = new String[]{'scontrol',SOAP_M_URI,null,'0','1','false'};
        private String[] showsLocation_type_info = new String[]{'showsLocation',SOAP_M_URI,null,'0','1','false'};
        private String[] showsStatus_type_info = new String[]{'showsStatus',SOAP_M_URI,null,'0','1','false'};
        private String[] url_type_info = new String[]{'url',SOAP_M_URI,null,'0','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'availability','description','displayType','encodingKey','hasMenubar','hasScrollbars','hasToolbar','height','isResizable','linkType','masterLabel','openType','page_x','position','protected_x','requireRowSelection','scontrol','showsLocation','showsStatus','url','width'};
    }
    
    public class LayoutColumn {
        public MetadataService.LayoutItem[] layoutItems;
        public String reserved;
        private String[] layoutItems_type_info = new String[]{'layoutItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] reserved_type_info = new String[]{'reserved',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'layoutItems','reserved'};
    }
    public class Error {
        public String[] fields;
        public String message;
        public String statusCode;
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'1','1','false'};
        private String[] statusCode_type_info = new String[]{'statusCode',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fields','message','statusCode'};
    }
    
    public class updateMetadata_element {
        public MetadataService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
    
   
    
    public class PlatformActionListItem {
        public String actionName;
        public String actionType;
        public Integer sortOrder;
        public String subtype;
        private String[] actionName_type_info = new String[]{'actionName',SOAP_M_URI,null,'1','1','false'};
        private String[] actionType_type_info = new String[]{'actionType',SOAP_M_URI,null,'1','1','false'};
        private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'1','1','false'};
        private String[] subtype_type_info = new String[]{'subtype',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'actionName','actionType','sortOrder','subtype'};
    }
    public class CallOptions_element {
        public String client;
        private String[] client_type_info = new String[]{'client',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'client'};
    }
   
    public class upsertMetadata_element {
        public MetadataService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
    public class deleteMetadata_element {
        public String type_x;
        public String[] fullNames;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] fullNames_type_info = new String[]{'fullNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x','fullNames'};
    }
    
    public class renameMetadata_element {
        public String type_x;
        public String oldFullName;
        public String newFullName;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] oldFullName_type_info = new String[]{'oldFullName',SOAP_M_URI,null,'1','1','false'};
        private String[] newFullName_type_info = new String[]{'newFullName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x','oldFullName','newFullName'};
    }
    
    
    
    public class Group_x extends Metadata {
        public String type = 'Group_x';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean doesIncludeBosses;
        public String name;
        private String[] doesIncludeBosses_type_info = new String[]{'doesIncludeBosses',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'doesIncludeBosses','name'};
    }
    
    public virtual class Metadata {
        public String fullName;
    }
    public class DebuggingHeader_element {
        public MetadataService.LogInfo[] categories;
        public String debugLevel;
        private String[] categories_type_info = new String[]{'categories',SOAP_M_URI,null,'0','-1','false'};
        private String[] debugLevel_type_info = new String[]{'debugLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'categories','debugLevel'};
    }
    public class LogInfo {
        public String category;
        public String level;
        private String[] category_type_info = new String[]{'category',SOAP_M_URI,null,'1','1','false'};
        private String[] level_type_info = new String[]{'level',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'category','level'};
    }
    public class describeMetadata_element {
        public Double asOfVersion;
        private String[] asOfVersion_type_info = new String[]{'asOfVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'asOfVersion'};
    }
    public class AnalyticsCloudComponentLayoutItem {
        public String assetType;
        public String devName;
        public String error;
        public String filter;
        public Integer height;
        public Boolean hideOnError;
        public Boolean showTitle;
        public String width;
        private String[] assetType_type_info = new String[]{'assetType',SOAP_M_URI,null,'1','1','false'};
        private String[] devName_type_info = new String[]{'devName',SOAP_M_URI,null,'1','1','false'};
        private String[] error_type_info = new String[]{'error',SOAP_M_URI,null,'0','1','false'};
        private String[] filter_type_info = new String[]{'filter',SOAP_M_URI,null,'0','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] hideOnError_type_info = new String[]{'hideOnError',SOAP_M_URI,null,'0','1','false'};
        private String[] showTitle_type_info = new String[]{'showTitle',SOAP_M_URI,null,'0','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'assetType','devName','error','filter','height','hideOnError','showTitle','width'};
    }
    public class ReportChartComponentLayoutItem {
        public Boolean cacheData;
        public String contextFilterableField;
        public String error;
        public Boolean hideOnError;
        public Boolean includeContext;
        public String reportName;
        public Boolean showTitle;
        public String size;
        private String[] cacheData_type_info = new String[]{'cacheData',SOAP_M_URI,null,'0','1','false'};
        private String[] contextFilterableField_type_info = new String[]{'contextFilterableField',SOAP_M_URI,null,'0','1','false'};
        private String[] error_type_info = new String[]{'error',SOAP_M_URI,null,'0','1','false'};
        private String[] hideOnError_type_info = new String[]{'hideOnError',SOAP_M_URI,null,'0','1','false'};
        private String[] includeContext_type_info = new String[]{'includeContext',SOAP_M_URI,null,'0','1','false'};
        private String[] reportName_type_info = new String[]{'reportName',SOAP_M_URI,null,'1','1','false'};
        private String[] showTitle_type_info = new String[]{'showTitle',SOAP_M_URI,null,'0','1','false'};
        private String[] size_type_info = new String[]{'size',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'cacheData','contextFilterableField','error','hideOnError','includeContext','reportName','showTitle','size'};
    }

    public class LayoutItem {
        public MetadataService.AnalyticsCloudComponentLayoutItem analyticsCloudComponent;
        public String behavior;
        public String canvas;
        public String component;
        public String customLink;
        public Boolean emptySpace;
        public String field;
        public Integer height;
        public String page_x;
        public MetadataService.ReportChartComponentLayoutItem reportChartComponent;
        public String scontrol;
        public Boolean showLabel;
        public Boolean showScrollbars;
        public String width;
        private String[] analyticsCloudComponent_type_info = new String[]{'analyticsCloudComponent',SOAP_M_URI,null,'0','1','false'};
        private String[] behavior_type_info = new String[]{'behavior',SOAP_M_URI,null,'0','1','false'};
        private String[] canvas_type_info = new String[]{'canvas',SOAP_M_URI,null,'0','1','false'};
        private String[] component_type_info = new String[]{'component',SOAP_M_URI,null,'0','1','false'};
        private String[] customLink_type_info = new String[]{'customLink',SOAP_M_URI,null,'0','1','false'};
        private String[] emptySpace_type_info = new String[]{'emptySpace',SOAP_M_URI,null,'0','1','false'};
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] reportChartComponent_type_info = new String[]{'reportChartComponent',SOAP_M_URI,null,'0','1','false'};
        private String[] scontrol_type_info = new String[]{'scontrol',SOAP_M_URI,null,'0','1','false'};
        private String[] showLabel_type_info = new String[]{'showLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] showScrollbars_type_info = new String[]{'showScrollbars',SOAP_M_URI,null,'0','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'analyticsCloudComponent','behavior','canvas','component','customLink','emptySpace','field','height','page_x','reportChartComponent','scontrol','showLabel','showScrollbars','width'};
    }
    
    public class ListMetadataQuery {
        public String folder;
        public String type_x;
        private String[] folder_type_info = new String[]{'folder',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'folder','type_x'};
    }
    
    public class QuickActionLayoutColumn {
        public MetadataService.QuickActionLayoutItem[] quickActionLayoutItems;
        private String[] quickActionLayoutItems_type_info = new String[]{'quickActionLayoutItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'quickActionLayoutItems'};
    }
    
    public class ProfileLayoutAssignment {
        public String layout;
        public String recordType;
        private String[] layout_type_info = new String[]{'layout',SOAP_M_URI,null,'1','1','false'};
        private String[] recordType_type_info = new String[]{'recordType',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'layout','recordType'};
    }
    public class QuickActionTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    
    public class ActionLinkGroupTemplate extends Metadata {
        public String type = 'ActionLinkGroupTemplate';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.ActionLinkTemplate[] actionLinkTemplates;
        public String category;
        public String executionsAllowed;
        public Integer hoursUntilExpiration;
        public Boolean isPublished;
        public String name;
        private String[] actionLinkTemplates_type_info = new String[]{'actionLinkTemplates',SOAP_M_URI,null,'0','-1','false'};
        private String[] category_type_info = new String[]{'category',SOAP_M_URI,null,'1','1','false'};
        private String[] executionsAllowed_type_info = new String[]{'executionsAllowed',SOAP_M_URI,null,'1','1','false'};
        private String[] hoursUntilExpiration_type_info = new String[]{'hoursUntilExpiration',SOAP_M_URI,null,'0','1','false'};
        private String[] isPublished_type_info = new String[]{'isPublished',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'actionLinkTemplates','category','executionsAllowed','hoursUntilExpiration','isPublished','name'};
    }
    
    public class createMetadataResponse_element {
        public MetadataService.SaveResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class RecordTypePicklistValue {
        public String picklist;
        public MetadataService.PicklistValue[] values;
        private String[] picklist_type_info = new String[]{'picklist',SOAP_M_URI,null,'1','1','false'};
        private String[] values_type_info = new String[]{'values',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'picklist','values'};
    }

    
    public class Container {
        public Integer height;
        public Boolean isContainerAutoSizeEnabled;
        public String region;
        public MetadataService.SidebarComponent[] sidebarComponents;
        public String style;
        public String unit;
        public Integer width;
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] isContainerAutoSizeEnabled_type_info = new String[]{'isContainerAutoSizeEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] region_type_info = new String[]{'region',SOAP_M_URI,null,'1','1','false'};
        private String[] sidebarComponents_type_info = new String[]{'sidebarComponents',SOAP_M_URI,null,'0','-1','false'};
        private String[] style_type_info = new String[]{'style',SOAP_M_URI,null,'1','1','false'};
        private String[] unit_type_info = new String[]{'unit',SOAP_M_URI,null,'1','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'height','isContainerAutoSizeEnabled','region','sidebarComponents','style','unit','width'};
    }
    public class FeedLayout {
        public Boolean autocollapsePublisher;
        public Boolean compactFeed;
        public String feedFilterPosition;
        public MetadataService.FeedLayoutFilter[] feedFilters;
        public Boolean fullWidthFeed;
        public Boolean hideSidebar;
        public Boolean highlightExternalFeedItems;
        public MetadataService.FeedLayoutComponent[] leftComponents;
        public MetadataService.FeedLayoutComponent[] rightComponents;
        public Boolean useInlineFiltersInConsole;
        private String[] autocollapsePublisher_type_info = new String[]{'autocollapsePublisher',SOAP_M_URI,null,'0','1','false'};
        private String[] compactFeed_type_info = new String[]{'compactFeed',SOAP_M_URI,null,'0','1','false'};
        private String[] feedFilterPosition_type_info = new String[]{'feedFilterPosition',SOAP_M_URI,null,'0','1','false'};
        private String[] feedFilters_type_info = new String[]{'feedFilters',SOAP_M_URI,null,'0','-1','false'};
        private String[] fullWidthFeed_type_info = new String[]{'fullWidthFeed',SOAP_M_URI,null,'0','1','false'};
        private String[] hideSidebar_type_info = new String[]{'hideSidebar',SOAP_M_URI,null,'0','1','false'};
        private String[] highlightExternalFeedItems_type_info = new String[]{'highlightExternalFeedItems',SOAP_M_URI,null,'0','1','false'};
        private String[] leftComponents_type_info = new String[]{'leftComponents',SOAP_M_URI,null,'0','-1','false'};
        private String[] rightComponents_type_info = new String[]{'rightComponents',SOAP_M_URI,null,'0','-1','false'};
        private String[] useInlineFiltersInConsole_type_info = new String[]{'useInlineFiltersInConsole',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'autocollapsePublisher','compactFeed','feedFilterPosition','feedFilters','fullWidthFeed','hideSidebar','highlightExternalFeedItems','leftComponents','rightComponents','useInlineFiltersInConsole'};
    }
    
    public class readMetadata_element {
        public String type_x;
        public String[] fullNames;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] fullNames_type_info = new String[]{'fullNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x','fullNames'};
    }
    
    public class QuickActionList {
        public MetadataService.QuickActionListItem[] quickActionListItems;
        private String[] quickActionListItems_type_info = new String[]{'quickActionListItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'quickActionListItems'};
    }
    public class FlexiPageRegion {
        public String appendable;
        public MetadataService.ComponentInstance[] componentInstances;
        public String mode;
        public String name;
        public String prependable;
        public String replaceable;
        public String type_x;
        private String[] appendable_type_info = new String[]{'appendable',SOAP_M_URI,null,'0','1','false'};
        private String[] componentInstances_type_info = new String[]{'componentInstances',SOAP_M_URI,null,'0','-1','false'};
        private String[] mode_type_info = new String[]{'mode',SOAP_M_URI,null,'0','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] prependable_type_info = new String[]{'prependable',SOAP_M_URI,null,'0','1','false'};
        private String[] replaceable_type_info = new String[]{'replaceable',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'appendable','componentInstances','mode','name','prependable','replaceable','type_x'};
    }
    public class PrimaryTabComponents {
        public MetadataService.Container[] containers;
        private String[] containers_type_info = new String[]{'containers',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'containers'};
    }
    
    public class updateMetadataResponse_element {
        public MetadataService.SaveResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class QuickActionListItem {
        public String quickActionName;
        private String[] quickActionName_type_info = new String[]{'quickActionName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'quickActionName'};
    }
    
    
    public class CustomApplicationComponent extends Metadata {
        public String type = 'CustomApplicationComponent';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String buttonIconUrl;
        public String buttonStyle;
        public String buttonText;
        public Integer buttonWidth;
        public Integer height;
        public Boolean isHeightFixed;
        public Boolean isHidden;
        public Boolean isWidthFixed;
        public String visualforcePage;
        public Integer width;
        private String[] buttonIconUrl_type_info = new String[]{'buttonIconUrl',SOAP_M_URI,null,'0','1','false'};
        private String[] buttonStyle_type_info = new String[]{'buttonStyle',SOAP_M_URI,null,'0','1','false'};
        private String[] buttonText_type_info = new String[]{'buttonText',SOAP_M_URI,null,'0','1','false'};
        private String[] buttonWidth_type_info = new String[]{'buttonWidth',SOAP_M_URI,null,'0','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] isHeightFixed_type_info = new String[]{'isHeightFixed',SOAP_M_URI,null,'1','1','false'};
        private String[] isHidden_type_info = new String[]{'isHidden',SOAP_M_URI,null,'1','1','false'};
        private String[] isWidthFixed_type_info = new String[]{'isWidthFixed',SOAP_M_URI,null,'1','1','false'};
        private String[] visualforcePage_type_info = new String[]{'visualforcePage',SOAP_M_URI,null,'1','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'buttonIconUrl','buttonStyle','buttonText','buttonWidth','height','isHeightFixed','isHidden','isWidthFixed','visualforcePage','width'};
    }
    public class ComponentInstanceProperty {
        public String name;
        public String value;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','value'};
    }
    
    public class OpportunityListFieldsSelectedSettings {
        public String[] field;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field'};
    }
    
    
    public class ListViewFilter {
        public String field;
        public String operation;
        public String value;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] operation_type_info = new String[]{'operation',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field','operation','value'};
    }
    
    public class ListPlacement {
        public Integer height;
        public String location;
        public String units;
        public Integer width;
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] location_type_info = new String[]{'location',SOAP_M_URI,null,'1','1','false'};
        private String[] units_type_info = new String[]{'units',SOAP_M_URI,null,'0','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'height','location','units','width'};
    }
    
    public class renameMetadataResponse_element {
        public MetadataService.SaveResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class RelatedList {
        public Boolean hideOnDetail;
        public String name;
        private String[] hideOnDetail_type_info = new String[]{'hideOnDetail',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'hideOnDetail','name'};
    }
    public class SynonymGroup {
        public String[] languages;
        public String[] terms;
        private String[] languages_type_info = new String[]{'languages',SOAP_M_URI,null,'0','-1','false'};
        private String[] terms_type_info = new String[]{'terms',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'languages','terms'};
    }
    
    public class CustomFeedFilter {
        public MetadataService.FeedFilterCriterion[] criteria;
        public String description;
        public Boolean isProtected;
        public String label;
        private String[] criteria_type_info = new String[]{'criteria',SOAP_M_URI,null,'0','-1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] isProtected_type_info = new String[]{'isProtected',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'criteria','description','isProtected','label'};
    }
    public class ProfileRecordTypeVisibility {
        public Boolean default_x;
        public Boolean personAccountDefault;
        public String recordType;
        public Boolean visible;
        private String[] default_x_type_info = new String[]{'default',SOAP_M_URI,null,'1','1','false'};
        private String[] personAccountDefault_type_info = new String[]{'personAccountDefault',SOAP_M_URI,null,'0','1','false'};
        private String[] recordType_type_info = new String[]{'recordType',SOAP_M_URI,null,'1','1','false'};
        private String[] visible_type_info = new String[]{'visible',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'default_x','personAccountDefault','recordType','visible'};
    }
    
    public interface IReadResult {
        MetadataService.Metadata[] getRecords();
    }
    public interface IReadResponseElement {
        IReadResult getResult();
    }
    
    public class ReadListViewResult implements IReadResult {
        public MetadataService.ListView[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readListViewResponse_element implements IReadResponseElement {
        public MetadataService.ReadListViewResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class ReadRecordTypeResult implements IReadResult {
        public MetadataService.RecordType[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readRecordTypeResponse_element implements IReadResponseElement {
        public MetadataService.ReadRecordTypeResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadWebLinkResult implements IReadResult {
        public MetadataService.WebLink[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readWebLinkResponse_element implements IReadResponseElement {
        public MetadataService.ReadWebLinkResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class ReadLayoutResult implements IReadResult {
        public MetadataService.Layout[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readLayoutResponse_element implements IReadResponseElement {
        public MetadataService.ReadLayoutResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class ReadGroupResult implements IReadResult {
        public MetadataService.Group_x[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readGroupResponse_element implements IReadResponseElement {
        public MetadataService.ReadGroupResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class ReadCompactLayoutResult implements IReadResult {
        public MetadataService.CompactLayout[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCompactLayoutResponse_element implements IReadResponseElement {
        public MetadataService.ReadCompactLayoutResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
   
    public class ReadCustomPageWebLinkResult implements IReadResult {
        public MetadataService.CustomPageWebLink[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomPageWebLinkResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomPageWebLinkResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadQuickActionResult implements IReadResult {
        public MetadataService.QuickAction[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readQuickActionResponse_element implements IReadResponseElement {
        public MetadataService.ReadQuickActionResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadFlexiPageResult implements IReadResult {
        public MetadataService.FlexiPage[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readFlexiPageResponse_element implements IReadResponseElement {
        public MetadataService.ReadFlexiPageResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadGlobalPicklistValueResult implements IReadResult {
        public MetadataService.GlobalPicklistValue[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readGlobalPicklistValueResponse_element implements IReadResponseElement {
        public MetadataService.ReadGlobalPicklistValueResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadPicklistValueResult implements IReadResult {
        public MetadataService.PicklistValue[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readPicklistValueResponse_element implements IReadResponseElement {
        public MetadataService.ReadPicklistValueResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadHomePageComponentResult implements IReadResult {
        public MetadataService.HomePageComponent[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readHomePageComponentResponse_element implements IReadResponseElement {
        public MetadataService.ReadHomePageComponentResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadHomePageLayoutResult implements IReadResult {
        public MetadataService.HomePageLayout[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readHomePageLayoutResponse_element implements IReadResponseElement {
        public MetadataService.ReadHomePageLayoutResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class ReadRemoteSiteSettingResult implements IReadResult {
        public MetadataService.RemoteSiteSetting[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readRemoteSiteSettingResponse_element implements IReadResponseElement {
        public MetadataService.ReadRemoteSiteSettingResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }

    public class ReadCustomObjectResult implements IReadResult {
        public MetadataService.CustomObject[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomObjectResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomObjectResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }

    public class ReadBusinessProcessResult implements IReadResult {
        public MetadataService.BusinessProcess[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readBusinessProcessResponse_element implements IReadResponseElement {
        public MetadataService.ReadBusinessProcessResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }

    public class ReadFieldSetResult implements IReadResult {
        public MetadataService.FieldSet[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }

    public class readFieldSetResponse_element implements IReadResponseElement {
        public MetadataService.ReadFieldSetResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }

    public class ReadCustomFieldResult implements IReadResult {
        public MetadataService.CustomField[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readCustomFieldResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomFieldResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }

    public class ReadSharingReasonResult implements IReadResult {
        public MetadataService.SharingReason[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readSharingReasonResponse_element implements IReadResponseElement {
        public MetadataService.ReadSharingReasonResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadValidationRuleResult implements IReadResult {
        public MetadataService.ValidationRule[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readValidationRuleResponse_element implements IReadResponseElement {
        public MetadataService.ReadValidationRuleResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    
    public class ReadCustomMetadataResult implements IReadResult {
        public MetadataService.CustomMetadata[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    
    public class ReadActionLinkGroupTemplateResult implements IReadResult {
        public MetadataService.ActionLinkGroupTemplate[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readActionLinkGroupTemplateResponse_element implements IReadResponseElement {
        public MetadataService.ReadActionLinkGroupTemplateResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class ReadMetadataWithContentResult implements IReadResult {
        public MetadataService.MetadataWithContent[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class readMetadataWithContentResponse_element implements IReadResponseElement {
        public MetadataService.ReadMetadataWithContentResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class ReadResult {
        public MetadataService.Metadata[] records;
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    
    public class ActionLinkTemplate {
        public String actionUrl;
        public String headers;
        public Boolean isConfirmationRequired;
        public Boolean isGroupDefault;
        public String label;
        public String labelKey;
        public String linkType;
        public String method;
        public Integer position;
        public String requestBody;
        public String userAlias;
        public String userVisibility;
        private String[] actionUrl_type_info = new String[]{'actionUrl',SOAP_M_URI,null,'1','1','false'};
        private String[] headers_type_info = new String[]{'headers',SOAP_M_URI,null,'0','1','false'};
        private String[] isConfirmationRequired_type_info = new String[]{'isConfirmationRequired',SOAP_M_URI,null,'1','1','false'};
        private String[] isGroupDefault_type_info = new String[]{'isGroupDefault',SOAP_M_URI,null,'1','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] labelKey_type_info = new String[]{'labelKey',SOAP_M_URI,null,'1','1','false'};
        private String[] linkType_type_info = new String[]{'linkType',SOAP_M_URI,null,'1','1','false'};
        private String[] method_type_info = new String[]{'method',SOAP_M_URI,null,'1','1','false'};
        private String[] position_type_info = new String[]{'position',SOAP_M_URI,null,'1','1','false'};
        private String[] requestBody_type_info = new String[]{'requestBody',SOAP_M_URI,null,'0','1','false'};
        private String[] userAlias_type_info = new String[]{'userAlias',SOAP_M_URI,null,'0','1','false'};
        private String[] userVisibility_type_info = new String[]{'userVisibility',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'actionUrl','headers','isConfirmationRequired','isGroupDefault','label','labelKey','linkType','method','position','requestBody','userAlias','userVisibility'};
    }
    
    public class LayoutSection {
        public Boolean customLabel;
        public Boolean detailHeading;
        public Boolean editHeading;
        public String label;
        public MetadataService.LayoutColumn[] layoutColumns;
        public String style;
        private String[] customLabel_type_info = new String[]{'customLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] detailHeading_type_info = new String[]{'detailHeading',SOAP_M_URI,null,'0','1','false'};
        private String[] editHeading_type_info = new String[]{'editHeading',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] layoutColumns_type_info = new String[]{'layoutColumns',SOAP_M_URI,null,'0','-1','false'};
        private String[] style_type_info = new String[]{'style',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'customLabel','detailHeading','editHeading','label','layoutColumns','style'};
    }
    
    public class FeedLayoutComponent {
        public String componentType;
        public Integer height;
        public String page_x;
        private String[] componentType_type_info = new String[]{'componentType',SOAP_M_URI,null,'1','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'componentType','height','page_x'};
    }
    
    public class DescribeMetadataResult {
        public MetadataService.DescribeMetadataObject[] metadataObjects;
        public String organizationNamespace;
        public Boolean partialSaveAllowed;
        public Boolean testRequired;
        private String[] metadataObjects_type_info = new String[]{'metadataObjects',SOAP_M_URI,null,'0','-1','false'};
        private String[] organizationNamespace_type_info = new String[]{'organizationNamespace',SOAP_M_URI,null,'1','1','false'};
        private String[] partialSaveAllowed_type_info = new String[]{'partialSaveAllowed',SOAP_M_URI,null,'1','1','false'};
        private String[] testRequired_type_info = new String[]{'testRequired',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadataObjects','organizationNamespace','partialSaveAllowed','testRequired'};
    }
    
    
    public class RemoteSiteSetting extends Metadata {
        public String type = 'RemoteSiteSetting';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public Boolean disableProtocolSecurity;
        public Boolean isActive;
        public String url;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] disableProtocolSecurity_type_info = new String[]{'disableProtocolSecurity',SOAP_M_URI,null,'1','1','false'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'1','1','false'};
        private String[] url_type_info = new String[]{'url',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','disableProtocolSecurity','isActive','url'};
    }
    
    public class Picklist {
        public String controllingField;
        public MetadataService.PicklistValue[] picklistValues;
        public Boolean sorted;
        private String[] controllingField_type_info = new String[]{'controllingField',SOAP_M_URI,null,'0','1','false'};
        private String[] picklistValues_type_info = new String[]{'picklistValues',SOAP_M_URI,null,'0','-1','false'};
        private String[] sorted_type_info = new String[]{'sorted',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'controllingField','picklistValues','sorted'};
    }
   
    
    public class PagesToOpen {
        public String[] pageToOpen;
        private String[] pageToOpen_type_info = new String[]{'pageToOpen',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'pageToOpen'};
    }
   
    public class LayoutTranslation {
        public String layout;
        public String layoutType;
        public MetadataService.LayoutSectionTranslation[] sections;
        private String[] layout_type_info = new String[]{'layout',SOAP_M_URI,null,'1','1','false'};
        private String[] layoutType_type_info = new String[]{'layoutType',SOAP_M_URI,null,'0','1','false'};
        private String[] sections_type_info = new String[]{'sections',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'layout','layoutType','sections'};
    }
    
    public class createMetadata_element {
        public MetadataService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
    public class CustomPageWebLinkTranslation {
        public String label;
        public String name;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'label','name'};
    }
    public class describeMetadataResponse_element {
        public MetadataService.DescribeMetadataResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
   
    public virtual class MetadataWithContent extends Metadata {
        public String content;
    }
    
    public class SummaryLayout {
        public String masterLabel;
        public Integer sizeX;
        public Integer sizeY;
        public Integer sizeZ;
        public MetadataService.SummaryLayoutItem[] summaryLayoutItems;
        public String summaryLayoutStyle;
        private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
        private String[] sizeX_type_info = new String[]{'sizeX',SOAP_M_URI,null,'1','1','false'};
        private String[] sizeY_type_info = new String[]{'sizeY',SOAP_M_URI,null,'0','1','false'};
        private String[] sizeZ_type_info = new String[]{'sizeZ',SOAP_M_URI,null,'0','1','false'};
        private String[] summaryLayoutItems_type_info = new String[]{'summaryLayoutItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] summaryLayoutStyle_type_info = new String[]{'summaryLayoutStyle',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'masterLabel','sizeX','sizeY','sizeZ','summaryLayoutItems','summaryLayoutStyle'};
    }
    public class QuickActionLayout {
        public String layoutSectionStyle;
        public MetadataService.QuickActionLayoutColumn[] quickActionLayoutColumns;
        private String[] layoutSectionStyle_type_info = new String[]{'layoutSectionStyle',SOAP_M_URI,null,'1','1','false'};
        private String[] quickActionLayoutColumns_type_info = new String[]{'quickActionLayoutColumns',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'layoutSectionStyle','quickActionLayoutColumns'};
    }
    
    public class listMetadataResponse_element {
        public MetadataService.FileProperties[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class SidebarComponent {
        public String componentType;
        public Integer height;
        public String label;
        public String lookup;
        public String page_x;
        public MetadataService.RelatedList[] relatedLists;
        public String unit;
        public Integer width;
        private String[] componentType_type_info = new String[]{'componentType',SOAP_M_URI,null,'1','1','false'};
        private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] lookup_type_info = new String[]{'lookup',SOAP_M_URI,null,'0','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] relatedLists_type_info = new String[]{'relatedLists',SOAP_M_URI,null,'0','-1','false'};
        private String[] unit_type_info = new String[]{'unit',SOAP_M_URI,null,'0','1','false'};
        private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'componentType','height','label','lookup','page_x','relatedLists','unit','width'};
    }
    
    public class FieldSetItem {
        public String field;
        public Boolean isFieldManaged;
        public Boolean isRequired;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','1','false'};
        private String[] isFieldManaged_type_info = new String[]{'isFieldManaged',SOAP_M_URI,null,'0','1','false'};
        private String[] isRequired_type_info = new String[]{'isRequired',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field','isFieldManaged','isRequired'};
    }
    
    public class MetadataPort {
        public String endpoint_x = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/35.0';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public MetadataService.SessionHeader_element SessionHeader;
        public MetadataService.DebuggingInfo_element DebuggingInfo;
        public MetadataService.DebuggingHeader_element DebuggingHeader;
        public MetadataService.CallOptions_element CallOptions;
        public MetadataService.AllOrNoneHeader_element AllOrNoneHeader;
        private String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/2006/04/metadata';
        private String DebuggingInfo_hns = 'DebuggingInfo=http://soap.sforce.com/2006/04/metadata';
        private String DebuggingHeader_hns = 'DebuggingHeader=http://soap.sforce.com/2006/04/metadata';
        private String CallOptions_hns = 'CallOptions=http://soap.sforce.com/2006/04/metadata';
        private String AllOrNoneHeader_hns = 'AllOrNoneHeader=http://soap.sforce.com/2006/04/metadata';
        private String[] ns_map_type_info = new String[]{SOAP_M_URI, 'MetadataService'};
        
        
        public MetadataService.SaveResult[] updateMetadata(MetadataService.Metadata[] metadata) {
            MetadataService.updateMetadata_element request_x = new MetadataService.updateMetadata_element();
            request_x.metadata = metadata;
            MetadataService.updateMetadataResponse_element response_x;
            Map<String, MetadataService.updateMetadataResponse_element> response_map_x = new Map<String, MetadataService.updateMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            if(!Test.isRunningTest())WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'updateMetadata',
              SOAP_M_URI,
              'updateMetadataResponse',
              'MetadataService.updateMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            if(!Test.isRunningTest()) return response_x.result;
            else return new List<MetadataService.SaveResult>();
        }
        /*public MetadataService.DescribeMetadataResult describeMetadata(Double asOfVersion) {
            MetadataService.describeMetadata_element request_x = new MetadataService.describeMetadata_element();
            request_x.asOfVersion = asOfVersion;
            MetadataService.describeMetadataResponse_element response_x;
            Map<String, MetadataService.describeMetadataResponse_element> response_map_x = new Map<String, MetadataService.describeMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'describeMetadata',
              SOAP_M_URI,
              'describeMetadataResponse',
              'MetadataService.describeMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }*/
        
        
        public MetadataService.SaveResult[] createMetadata(MetadataService.Metadata[] metadata) {
            MetadataService.createMetadata_element request_x = new MetadataService.createMetadata_element();
            request_x.metadata = metadata;
            MetadataService.createMetadataResponse_element response_x;
            Map<String, MetadataService.createMetadataResponse_element> response_map_x = new Map<String, MetadataService.createMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'createMetadata',
              SOAP_M_URI,
              'createMetadataResponse',
              'MetadataService.createMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        
        public MetadataService.IReadResult readMetadata(String type_x,String[] fullNames) {
            MetadataService.readMetadata_element request_x = new MetadataService.readMetadata_element();
            request_x.type_x = type_x;
            request_x.fullNames = fullNames;
            MetadataService.IReadResponseElement response_x;
            Map<String, MetadataService.IReadResponseElement> response_map_x = new Map<String, MetadataService.IReadResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'readMetadata',
              SOAP_M_URI,
              'readMetadataResponse',
              'MetadataService.read' + type_x + 'Response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.getResult();
        }
        public MetadataService.UpsertResult[] upsertMetadata(MetadataService.Metadata[] metadata) {
            MetadataService.upsertMetadata_element request_x = new MetadataService.upsertMetadata_element();
            request_x.metadata = metadata;
            MetadataService.upsertMetadataResponse_element response_x;
            Map<String, MetadataService.upsertMetadataResponse_element> response_map_x = new Map<String, MetadataService.upsertMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'upsertMetadata',
              SOAP_M_URI,
              'upsertMetadataResponse',
              'MetadataService.upsertMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public MetadataService.FileProperties[] listMetadata(MetadataService.ListMetadataQuery[] queries,Double asOfVersion) {
            MetadataService.listMetadata_element request_x = new MetadataService.listMetadata_element();
            request_x.queries = queries;
            request_x.asOfVersion = asOfVersion;
            MetadataService.listMetadataResponse_element response_x;
            Map<String, MetadataService.listMetadataResponse_element> response_map_x = new Map<String, MetadataService.listMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            if(!Test.isRunningTest()) WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'listMetadata',
              SOAP_M_URI,
              'listMetadataResponse',
              'MetadataService.listMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            if(Test.isRunningTest()) return new List<MetadataService.FileProperties>();
            else return response_x.result;
        }
        
        public MetadataService.DeleteResult[] deleteMetadata(String type_x, String[] fullNames) {
            MetadataService.deleteMetadata_element request_x = new MetadataService.deleteMetadata_element();
            request_x.type_x = type_x;
            request_x.fullNames = fullNames;
            MetadataService.deleteMetadataResponse_element response_x;
            Map<String, MetadataService.deleteMetadataResponse_element> response_map_x = new Map<String, MetadataService.deleteMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'deleteMetadata',
              SOAP_M_URI,
              'deleteMetadataResponse',
              'MetadataService.deleteMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        
    }
    
    public class CustomApplication extends Metadata {
        public String type = 'CustomApplication';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.CustomApplicationComponents customApplicationComponents;
        public String defaultLandingTab;
        public String description;
        public String detailPageRefreshMethod;
        public MetadataService.DomainWhitelist domainWhitelist;
        public Boolean enableCustomizeMyTabs;
        public Boolean enableKeyboardShortcuts;
        public Boolean enableListViewReskin;
        public Boolean enableMultiMonitorComponents;
        public Boolean enablePinTabs;
        public Boolean enableTabHover;
        public Boolean enableTabLimits;
        public String footerColor;
        public String headerColor;
        public Boolean isServiceCloudConsole;
        //public MetadataService.KeyboardShortcuts keyboardShortcuts;
        public String label;
        public MetadataService.ListPlacement listPlacement;
        public String listRefreshMethod;
        //public MetadataService.LiveAgentConfig liveAgentConfig;
        public String logo;
        public String primaryTabColor;
        //public MetadataService.PushNotifications pushNotifications;
        public Boolean saveUserSessions;
        public String[] tab;
        public MetadataService.TabLimitConfig tabLimitConfig;
        //public MetadataService.WorkspaceMappings workspaceMappings;
        private String[] customApplicationComponents_type_info = new String[]{'customApplicationComponents',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultLandingTab_type_info = new String[]{'defaultLandingTab',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] detailPageRefreshMethod_type_info = new String[]{'detailPageRefreshMethod',SOAP_M_URI,null,'0','1','false'};
        private String[] domainWhitelist_type_info = new String[]{'domainWhitelist',SOAP_M_URI,null,'0','1','false'};
        private String[] enableCustomizeMyTabs_type_info = new String[]{'enableCustomizeMyTabs',SOAP_M_URI,null,'0','1','false'};
        //private String[] enableKeyboardShortcuts_type_info = new String[]{'enableKeyboardShortcuts',SOAP_M_URI,null,'0','1','false'};
        private String[] enableListViewReskin_type_info = new String[]{'enableListViewReskin',SOAP_M_URI,null,'0','1','false'};
        private String[] enableMultiMonitorComponents_type_info = new String[]{'enableMultiMonitorComponents',SOAP_M_URI,null,'0','1','false'};
        private String[] enablePinTabs_type_info = new String[]{'enablePinTabs',SOAP_M_URI,null,'0','1','false'};
        private String[] enableTabHover_type_info = new String[]{'enableTabHover',SOAP_M_URI,null,'0','1','false'};
        private String[] enableTabLimits_type_info = new String[]{'enableTabLimits',SOAP_M_URI,null,'0','1','false'};
        private String[] footerColor_type_info = new String[]{'footerColor',SOAP_M_URI,null,'0','1','false'};
        private String[] headerColor_type_info = new String[]{'headerColor',SOAP_M_URI,null,'0','1','false'};
        private String[] isServiceCloudConsole_type_info = new String[]{'isServiceCloudConsole',SOAP_M_URI,null,'0','1','false'};
        //private String[] keyboardShortcuts_type_info = new String[]{'keyboardShortcuts',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] listPlacement_type_info = new String[]{'listPlacement',SOAP_M_URI,null,'0','1','false'};
        private String[] listRefreshMethod_type_info = new String[]{'listRefreshMethod',SOAP_M_URI,null,'0','1','false'};
        //private String[] liveAgentConfig_type_info = new String[]{'liveAgentConfig',SOAP_M_URI,null,'0','1','false'};
        private String[] logo_type_info = new String[]{'logo',SOAP_M_URI,null,'0','1','false'};
        private String[] primaryTabColor_type_info = new String[]{'primaryTabColor',SOAP_M_URI,null,'0','1','false'};
        //private String[] pushNotifications_type_info = new String[]{'pushNotifications',SOAP_M_URI,null,'0','1','false'};
        //private String[] saveUserSessions_type_info = new String[]{'saveUserSessions',SOAP_M_URI,null,'0','1','false'};
        private String[] tab_type_info = new String[]{'tab',SOAP_M_URI,null,'0','-1','false'};
        private String[] tabLimitConfig_type_info = new String[]{'tabLimitConfig',SOAP_M_URI,null,'0','1','false'};
        //private String[] workspaceMappings_type_info = new String[]{'workspaceMappings',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'customApplicationComponents','defaultLandingTab','description','detailPageRefreshMethod','domainWhitelist','enableCustomizeMyTabs','enableListViewReskin','enableMultiMonitorComponents','enablePinTabs','enableTabHover','enableTabLimits','footerColor','headerColor','isServiceCloudConsole','label','listPlacement','listRefreshMethod','logo','primaryTabColor','tab', 'tabLimitConfig'};
    }
    public class CustomApplicationComponents {
        public String alignment;
        public String[] customApplicationComponent;
        private String[] alignment_type_info = new String[]{'alignment',SOAP_M_URI,null,'1','1','false'};
        private String[] customApplicationComponent_type_info = new String[]{'customApplicationComponent',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'alignment','customApplicationComponent'};
    }
    public class DomainWhitelist {
        public String[] domain;
        private String[] domain_type_info = new String[]{'domain',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'domain'};
    }
    public class readCustomApplicationResponse_element implements IReadResponseElement {
        public MetadataService.ReadCustomApplicationResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class ReadCustomApplicationResult implements IReadResult {
        public MetadataService.CustomApplication[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }

    public class TabLimitConfig {
        public String maxNumberOfPrimaryTabs;
        public String maxNumberOfSubTabs;
        private String[] maxNumberOfPrimaryTabs_type_info = new String[]{'maxNumberOfPrimaryTabs',SOAP_M_URI,null,'0','1','false'};
        private String[] maxNumberOfSubTabs_type_info = new String[]{'maxNumberOfSubTabs',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'maxNumberOfPrimaryTabs','maxNumberOfSubTabs'};
    }
    

    public class CustomObject extends Metadata {
        public String type = 'CustomObject';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public MetadataService.ActionOverride[] actionOverrides;
        public Boolean allowInChatterGroups;
        public MetadataService.ArticleTypeChannelDisplay articleTypeChannelDisplay;
        public MetadataService.BusinessProcess[] businessProcesses;
        public String compactLayoutAssignment;
        public MetadataService.CompactLayout[] compactLayouts;
        public String customHelp;
        public String customHelpPage;
        public String customSettingsType;
        public String dataStewardGroup;
        public String dataStewardUser;
        public String deploymentStatus;
        public Boolean deprecated;
        public String description;
        public Boolean enableActivities;
        public Boolean enableBulkApi;
        public Boolean enableChangeDataCapture;
        public Boolean enableDivisions;
        public Boolean enableEnhancedLookup;
        public Boolean enableFeeds;
        public Boolean enableHistory;
        public Boolean enableReports;
        public Boolean enableSearch;
        public Boolean enableSharing;
        public Boolean enableStreamingApi;
        public String eventType;
        public String externalDataSource;
        public String externalName;
        public String externalRepository;
        public String externalSharingModel;
        public MetadataService.FieldSet[] fieldSets;
        public MetadataService.CustomField[] fields;
        public String gender;
        public MetadataService.HistoryRetentionPolicy historyRetentionPolicy;
        public Boolean household;
        public MetadataService.Index[] indexes;
        public String label;
        public MetadataService.ListView[] listViews;
        public MetadataService.CustomField nameField;
        public String pluralLabel;
        public Boolean recordTypeTrackFeedHistory;
        public Boolean recordTypeTrackHistory;
        public MetadataService.RecordType[] recordTypes;
        public MetadataService.SearchLayouts searchLayouts;
        public String sharingModel;
        public MetadataService.SharingReason[] sharingReasons;
        public MetadataService.SharingRecalculation[] sharingRecalculations;
        public String startsWith;
        public MetadataService.ValidationRule[] validationRules;
        public String visibility;
        public MetadataService.WebLink[] webLinks;
        private String[] actionOverrides_type_info = new String[]{'actionOverrides',SOAP_M_URI,null,'0','-1','false'};
        private String[] allowInChatterGroups_type_info = new String[]{'allowInChatterGroups',SOAP_M_URI,null,'0','1','false'};
        private String[] articleTypeChannelDisplay_type_info = new String[]{'articleTypeChannelDisplay',SOAP_M_URI,null,'0','1','false'};
        private String[] businessProcesses_type_info = new String[]{'businessProcesses',SOAP_M_URI,null,'0','-1','false'};
        private String[] compactLayoutAssignment_type_info = new String[]{'compactLayoutAssignment',SOAP_M_URI,null,'0','1','false'};
        private String[] compactLayouts_type_info = new String[]{'compactLayouts',SOAP_M_URI,null,'0','-1','false'};
        private String[] customHelp_type_info = new String[]{'customHelp',SOAP_M_URI,null,'0','1','false'};
        private String[] customHelpPage_type_info = new String[]{'customHelpPage',SOAP_M_URI,null,'0','1','false'};
        private String[] customSettingsType_type_info = new String[]{'customSettingsType',SOAP_M_URI,null,'0','1','false'};
        private String[] dataStewardGroup_type_info = new String[]{'dataStewardGroup',SOAP_M_URI,null,'0','1','false'};
        private String[] dataStewardUser_type_info = new String[]{'dataStewardUser',SOAP_M_URI,null,'0','1','false'};
        private String[] deploymentStatus_type_info = new String[]{'deploymentStatus',SOAP_M_URI,null,'0','1','false'};
        private String[] deprecated_type_info = new String[]{'deprecated',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] enableActivities_type_info = new String[]{'enableActivities',SOAP_M_URI,null,'0','1','false'};
        private String[] enableBulkApi_type_info = new String[]{'enableBulkApi',SOAP_M_URI,null,'0','1','false'};
        private String[] enableChangeDataCapture_type_info = new String[]{'enableChangeDataCapture',SOAP_M_URI,null,'0','1','false'};
        private String[] enableDivisions_type_info = new String[]{'enableDivisions',SOAP_M_URI,null,'0','1','false'};
        private String[] enableEnhancedLookup_type_info = new String[]{'enableEnhancedLookup',SOAP_M_URI,null,'0','1','false'};
        private String[] enableFeeds_type_info = new String[]{'enableFeeds',SOAP_M_URI,null,'0','1','false'};
        private String[] enableHistory_type_info = new String[]{'enableHistory',SOAP_M_URI,null,'0','1','false'};
        private String[] enableReports_type_info = new String[]{'enableReports',SOAP_M_URI,null,'0','1','false'};
        private String[] enableSearch_type_info = new String[]{'enableSearch',SOAP_M_URI,null,'0','1','false'};
        private String[] enableSharing_type_info = new String[]{'enableSharing',SOAP_M_URI,null,'0','1','false'};
        private String[] enableStreamingApi_type_info = new String[]{'enableStreamingApi',SOAP_M_URI,null,'0','1','false'};
        private String[] eventType_type_info = new String[]{'eventType',SOAP_M_URI,null,'0','1','false'};
        private String[] externalDataSource_type_info = new String[]{'externalDataSource',SOAP_M_URI,null,'0','1','false'};
        private String[] externalName_type_info = new String[]{'externalName',SOAP_M_URI,null,'0','1','false'};
        private String[] externalRepository_type_info = new String[]{'externalRepository',SOAP_M_URI,null,'0','1','false'};
        private String[] externalSharingModel_type_info = new String[]{'externalSharingModel',SOAP_M_URI,null,'0','1','false'};
        private String[] fieldSets_type_info = new String[]{'fieldSets',SOAP_M_URI,null,'0','-1','false'};
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] gender_type_info = new String[]{'gender',SOAP_M_URI,null,'0','1','false'};
        private String[] historyRetentionPolicy_type_info = new String[]{'historyRetentionPolicy',SOAP_M_URI,null,'0','1','false'};
        private String[] household_type_info = new String[]{'household',SOAP_M_URI,null,'0','1','false'};
        private String[] indexes_type_info = new String[]{'indexes',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] listViews_type_info = new String[]{'listViews',SOAP_M_URI,null,'0','-1','false'};
        private String[] nameField_type_info = new String[]{'nameField',SOAP_M_URI,null,'0','1','false'};
        private String[] pluralLabel_type_info = new String[]{'pluralLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] recordTypeTrackFeedHistory_type_info = new String[]{'recordTypeTrackFeedHistory',SOAP_M_URI,null,'0','1','false'};
        private String[] recordTypeTrackHistory_type_info = new String[]{'recordTypeTrackHistory',SOAP_M_URI,null,'0','1','false'};
        private String[] recordTypes_type_info = new String[]{'recordTypes',SOAP_M_URI,null,'0','-1','false'};
        private String[] searchLayouts_type_info = new String[]{'searchLayouts',SOAP_M_URI,null,'0','1','false'};
        private String[] sharingModel_type_info = new String[]{'sharingModel',SOAP_M_URI,null,'0','1','false'};
        private String[] sharingReasons_type_info = new String[]{'sharingReasons',SOAP_M_URI,null,'0','-1','false'};
        private String[] sharingRecalculations_type_info = new String[]{'sharingRecalculations',SOAP_M_URI,null,'0','-1','false'};
        private String[] startsWith_type_info = new String[]{'startsWith',SOAP_M_URI,null,'0','1','false'};
        private String[] validationRules_type_info = new String[]{'validationRules',SOAP_M_URI,null,'0','-1','false'};
        private String[] visibility_type_info = new String[]{'visibility',SOAP_M_URI,null,'0','1','false'};
        private String[] webLinks_type_info = new String[]{'webLinks',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'actionOverrides','allowInChatterGroups','articleTypeChannelDisplay','businessProcesses','compactLayoutAssignment','compactLayouts','customHelp','customHelpPage','customSettingsType','dataStewardGroup','dataStewardUser','deploymentStatus','deprecated','description','enableActivities','enableBulkApi','enableChangeDataCapture','enableDivisions','enableEnhancedLookup','enableFeeds','enableHistory','enableReports','enableSearch','enableSharing','enableStreamingApi','eventType','externalDataSource','externalName','externalRepository','externalSharingModel','fieldSets','fields','gender','historyRetentionPolicy','household','indexes','label','listViews','nameField','pluralLabel','recordTypeTrackFeedHistory','recordTypeTrackHistory','recordTypes','searchLayouts','sharingModel','sharingReasons','sharingRecalculations','startsWith','validationRules','visibility','webLinks'};
    }

    public class ActionOverride {
        public String actionName;
        public String comment;
        public String content;
        public String formFactor;
        public Boolean skipRecordTypeSelect;
        public String type_x;
        private String[] actionName_type_info = new String[]{'actionName',SOAP_M_URI,null,'0','1','false'};
        private String[] comment_type_info = new String[]{'comment',SOAP_M_URI,null,'0','1','false'};
        private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
        private String[] formFactor_type_info = new String[]{'formFactor',SOAP_M_URI,null,'0','1','false'};
        private String[] skipRecordTypeSelect_type_info = new String[]{'skipRecordTypeSelect',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'actionName','comment','content','formFactor','skipRecordTypeSelect','type_x'};
    }

    public class ArticleTypeChannelDisplay {
        public MetadataService.ArticleTypeTemplate[] articleTypeTemplates;
        private String[] articleTypeTemplates_type_info = new String[]{'articleTypeTemplates',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'articleTypeTemplates'};
    }

    public class ArticleTypeTemplate {
        public String channel;
        public String page_x;
        public String template;
        private String[] channel_type_info = new String[]{'channel',SOAP_M_URI,null,'1','1','false'};
        private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
        private String[] template_type_info = new String[]{'template',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'channel','page_x','template'};
    }

    public class BusinessProcess extends Metadata {
        public String type = 'BusinessProcess';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String description;
        public Boolean isActive;
        public MetadataService.PicklistValue[] values;
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'0','1','false'};
        private String[] values_type_info = new String[]{'values',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','isActive','values'};
    }

    public virtual class GlobalPicklistValue extends Metadata {
        public String color;
        public Boolean default_x;
        public String description;
        public Boolean isActive;
    }

    public class PicklistValue extends GlobalPicklistValue {
        public String type = 'PicklistValue';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String color;
        public Boolean default_x;
        public String description;
        public Boolean isActive;
        private String[] color_type_info = new String[]{'color',SOAP_M_URI,null,'0','1','false'};
        private String[] default_x_type_info = new String[]{'default',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'0','1','false'};
        public Boolean allowEmail;
        public Boolean closed;
        public String[] controllingFieldValues;
        public Boolean converted;
        public Boolean cssExposed;
        public String forecastCategory;
        public Boolean highPriority;
        public Integer probability;
        public String reverseRole;
        public Boolean reviewed;
        public Boolean won;
        private String[] allowEmail_type_info = new String[]{'allowEmail',SOAP_M_URI,null,'0','1','false'};
        private String[] closed_type_info = new String[]{'closed',SOAP_M_URI,null,'0','1','false'};
        private String[] controllingFieldValues_type_info = new String[]{'controllingFieldValues',SOAP_M_URI,null,'0','-1','false'};
        private String[] converted_type_info = new String[]{'converted',SOAP_M_URI,null,'0','1','false'};
        private String[] cssExposed_type_info = new String[]{'cssExposed',SOAP_M_URI,null,'0','1','false'};
        private String[] forecastCategory_type_info = new String[]{'forecastCategory',SOAP_M_URI,null,'0','1','false'};
        private String[] highPriority_type_info = new String[]{'highPriority',SOAP_M_URI,null,'0','1','false'};
        private String[] probability_type_info = new String[]{'probability',SOAP_M_URI,null,'0','1','false'};
        private String[] reverseRole_type_info = new String[]{'reverseRole',SOAP_M_URI,null,'0','1','false'};
        private String[] reviewed_type_info = new String[]{'reviewed',SOAP_M_URI,null,'0','1','false'};
        private String[] won_type_info = new String[]{'won',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName','color','default_x','description','isActive', 'allowEmail','closed','controllingFieldValues','converted','cssExposed','forecastCategory','highPriority','probability','reverseRole','reviewed','won'};
    }

    public class CustomField extends Metadata {
        public String type = 'CustomField';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String businessOwnerGroup;
        public String businessOwnerUser;
        public String businessStatus;
        public Boolean caseSensitive;
        public String customDataType;
        public String defaultValue;
        public String deleteConstraint;
        public Boolean deprecated;
        public String description;
        public String displayFormat;
        public Boolean displayLocationInDecimal;
        public Boolean encrypted;
        public Boolean escapeMarkup;
        public String externalDeveloperName;
        public Boolean externalId;
        public String fieldManageability;
        public String formula;
        public String formulaTreatBlanksAs;
        public String inlineHelpText;
        public Boolean isConvertLeadDisabled;
        public Boolean isFilteringDisabled;
        public Boolean isNameField;
        public Boolean isSortingDisabled;
        public String label;
        public Integer length;
        public MetadataService.LookupFilter lookupFilter;
        public String maskChar;
        public String maskType;
        public String metadataRelationshipControllingField;
        public Boolean populateExistingRows;
        public Integer precision;
        public String referenceTargetField;
        public String referenceTo;
        public String relationshipLabel;
        public String relationshipName;
        public Integer relationshipOrder;
        public Boolean reparentableMasterDetail;
        public Boolean required;
        public Boolean restrictedAdminField;
        public Integer scale;
        public String securityClassification;
        public Integer startingNumber;
        public Boolean stripMarkup;
        public String summarizedField;
        public MetadataService.FilterItem[] summaryFilterItems;
        public String summaryForeignKey;
        public String summaryOperation;
        public Boolean trackFeedHistory;
        public Boolean trackHistory;
        public Boolean trackTrending;
        public String type_x;
        public Boolean unique;
        public MetadataService.ValueSet valueSet;
        public Integer visibleLines;
        public Boolean writeRequiresMasterRead;
        private String[] businessOwnerGroup_type_info = new String[]{'businessOwnerGroup',SOAP_M_URI,null,'0','1','false'};
        private String[] businessOwnerUser_type_info = new String[]{'businessOwnerUser',SOAP_M_URI,null,'0','1','false'};
        private String[] businessStatus_type_info = new String[]{'businessStatus',SOAP_M_URI,null,'0','1','false'};
        private String[] caseSensitive_type_info = new String[]{'caseSensitive',SOAP_M_URI,null,'0','1','false'};
        private String[] customDataType_type_info = new String[]{'customDataType',SOAP_M_URI,null,'0','1','false'};
        private String[] defaultValue_type_info = new String[]{'defaultValue',SOAP_M_URI,null,'0','1','false'};
        private String[] deleteConstraint_type_info = new String[]{'deleteConstraint',SOAP_M_URI,null,'0','1','false'};
        private String[] deprecated_type_info = new String[]{'deprecated',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] displayFormat_type_info = new String[]{'displayFormat',SOAP_M_URI,null,'0','1','false'};
        private String[] displayLocationInDecimal_type_info = new String[]{'displayLocationInDecimal',SOAP_M_URI,null,'0','1','false'};
        private String[] encrypted_type_info = new String[]{'encrypted',SOAP_M_URI,null,'0','1','false'};
        private String[] escapeMarkup_type_info = new String[]{'escapeMarkup',SOAP_M_URI,null,'0','1','false'};
        private String[] externalDeveloperName_type_info = new String[]{'externalDeveloperName',SOAP_M_URI,null,'0','1','false'};
        private String[] externalId_type_info = new String[]{'externalId',SOAP_M_URI,null,'0','1','false'};
        private String[] fieldManageability_type_info = new String[]{'fieldManageability',SOAP_M_URI,null,'0','1','false'};
        private String[] formula_type_info = new String[]{'formula',SOAP_M_URI,null,'0','1','false'};
        private String[] formulaTreatBlanksAs_type_info = new String[]{'formulaTreatBlanksAs',SOAP_M_URI,null,'0','1','false'};
        private String[] inlineHelpText_type_info = new String[]{'inlineHelpText',SOAP_M_URI,null,'0','1','false'};
        private String[] isConvertLeadDisabled_type_info = new String[]{'isConvertLeadDisabled',SOAP_M_URI,null,'0','1','false'};
        private String[] isFilteringDisabled_type_info = new String[]{'isFilteringDisabled',SOAP_M_URI,null,'0','1','false'};
        private String[] isNameField_type_info = new String[]{'isNameField',SOAP_M_URI,null,'0','1','false'};
        private String[] isSortingDisabled_type_info = new String[]{'isSortingDisabled',SOAP_M_URI,null,'0','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
        private String[] length_type_info = new String[]{'length',SOAP_M_URI,null,'0','1','false'};
        private String[] lookupFilter_type_info = new String[]{'lookupFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] maskChar_type_info = new String[]{'maskChar',SOAP_M_URI,null,'0','1','false'};
        private String[] maskType_type_info = new String[]{'maskType',SOAP_M_URI,null,'0','1','false'};
        private String[] metadataRelationshipControllingField_type_info = new String[]{'metadataRelationshipControllingField',SOAP_M_URI,null,'0','1','false'};
        private String[] populateExistingRows_type_info = new String[]{'populateExistingRows',SOAP_M_URI,null,'0','1','false'};
        private String[] precision_type_info = new String[]{'precision',SOAP_M_URI,null,'0','1','false'};
        private String[] referenceTargetField_type_info = new String[]{'referenceTargetField',SOAP_M_URI,null,'0','1','false'};
        private String[] referenceTo_type_info = new String[]{'referenceTo',SOAP_M_URI,null,'0','1','false'};
        private String[] relationshipLabel_type_info = new String[]{'relationshipLabel',SOAP_M_URI,null,'0','1','false'};
        private String[] relationshipName_type_info = new String[]{'relationshipName',SOAP_M_URI,null,'0','1','false'};
        private String[] relationshipOrder_type_info = new String[]{'relationshipOrder',SOAP_M_URI,null,'0','1','false'};
        private String[] reparentableMasterDetail_type_info = new String[]{'reparentableMasterDetail',SOAP_M_URI,null,'0','1','false'};
        private String[] required_type_info = new String[]{'required',SOAP_M_URI,null,'0','1','false'};
        private String[] restrictedAdminField_type_info = new String[]{'restrictedAdminField',SOAP_M_URI,null,'0','1','false'};
        private String[] scale_type_info = new String[]{'scale',SOAP_M_URI,null,'0','1','false'};
        private String[] securityClassification_type_info = new String[]{'securityClassification',SOAP_M_URI,null,'0','1','false'};
        private String[] startingNumber_type_info = new String[]{'startingNumber',SOAP_M_URI,null,'0','1','false'};
        private String[] stripMarkup_type_info = new String[]{'stripMarkup',SOAP_M_URI,null,'0','1','false'};
        private String[] summarizedField_type_info = new String[]{'summarizedField',SOAP_M_URI,null,'0','1','false'};
        private String[] summaryFilterItems_type_info = new String[]{'summaryFilterItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] summaryForeignKey_type_info = new String[]{'summaryForeignKey',SOAP_M_URI,null,'0','1','false'};
        private String[] summaryOperation_type_info = new String[]{'summaryOperation',SOAP_M_URI,null,'0','1','false'};
        private String[] trackFeedHistory_type_info = new String[]{'trackFeedHistory',SOAP_M_URI,null,'0','1','false'};
        private String[] trackHistory_type_info = new String[]{'trackHistory',SOAP_M_URI,null,'0','1','false'};
        private String[] trackTrending_type_info = new String[]{'trackTrending',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'0','1','false'};
        private String[] unique_type_info = new String[]{'unique',SOAP_M_URI,null,'0','1','false'};
        private String[] valueSet_type_info = new String[]{'valueSet',SOAP_M_URI,null,'0','1','false'};
        private String[] visibleLines_type_info = new String[]{'visibleLines',SOAP_M_URI,null,'0','1','false'};
        private String[] writeRequiresMasterRead_type_info = new String[]{'writeRequiresMasterRead',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'businessOwnerGroup','businessOwnerUser','businessStatus','caseSensitive','customDataType','defaultValue','deleteConstraint','deprecated','description','displayFormat','displayLocationInDecimal','encrypted','escapeMarkup','externalDeveloperName','externalId','fieldManageability','formula','formulaTreatBlanksAs','inlineHelpText','isConvertLeadDisabled','isFilteringDisabled','isNameField','isSortingDisabled','label','length','lookupFilter','maskChar','maskType','metadataRelationshipControllingField','populateExistingRows','precision','referenceTargetField','referenceTo','relationshipLabel','relationshipName','relationshipOrder','reparentableMasterDetail','required','restrictedAdminField','scale','securityClassification','startingNumber','stripMarkup','summarizedField','summaryFilterItems','summaryForeignKey','summaryOperation','trackFeedHistory','trackHistory','trackTrending','type_x','unique','valueSet','visibleLines','writeRequiresMasterRead'};
    }

    public class LookupFilter {
        public Boolean active;
        public String booleanFilter;
        public String description;
        public String errorMessage;
        public MetadataService.FilterItem[] filterItems;
        public String infoMessage;
        public Boolean isOptional;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] booleanFilter_type_info = new String[]{'booleanFilter',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'0','1','false'};
        private String[] filterItems_type_info = new String[]{'filterItems',SOAP_M_URI,null,'0','-1','false'};
        private String[] infoMessage_type_info = new String[]{'infoMessage',SOAP_M_URI,null,'0','1','false'};
        private String[] isOptional_type_info = new String[]{'isOptional',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'active','booleanFilter','description','errorMessage','filterItems','infoMessage','isOptional'};
    }

    public class FilterItem {
        public String field;
        public String operation;
        public String value;
        public String valueField;
        private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
        private String[] operation_type_info = new String[]{'operation',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
        private String[] valueField_type_info = new String[]{'valueField',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'field','operation','value','valueField'};
    }

    public class ValueSet {
        public String controllingField;
        public Boolean restricted;
        public MetadataService.ValueSetValuesDefinition valueSetDefinition;
        public String valueSetName;
        public MetadataService.ValueSettings[] valueSettings;
        private String[] controllingField_type_info = new String[]{'controllingField',SOAP_M_URI,null,'0','1','false'};
        private String[] restricted_type_info = new String[]{'restricted',SOAP_M_URI,null,'0','1','false'};
        private String[] valueSetDefinition_type_info = new String[]{'valueSetDefinition',SOAP_M_URI,null,'0','1','false'};
        private String[] valueSetName_type_info = new String[]{'valueSetName',SOAP_M_URI,null,'0','1','false'};
        private String[] valueSettings_type_info = new String[]{'valueSettings',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'controllingField','restricted','valueSetDefinition','valueSetName','valueSettings'};
    }

    public class ValueSetValuesDefinition {
        public Boolean sorted;
        public MetadataService.CustomValue[] value;
        private String[] sorted_type_info = new String[]{'sorted',SOAP_M_URI,null,'1','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'sorted','value'};
    }

    public virtual class CustomValue extends Metadata {
        public String color;
        public Boolean default_x;
        public String description;
        public Boolean isActive;
        public String label;
    }

    public class ValueSettings {
        public String[] controllingFieldValue;
        public String valueName;
        private String[] controllingFieldValue_type_info = new String[]{'controllingFieldValue',SOAP_M_URI,null,'0','-1','false'};
        private String[] valueName_type_info = new String[]{'valueName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'controllingFieldValue','valueName'};
    }

    public class HistoryRetentionPolicy {
        public Integer archiveAfterMonths;
        public Integer archiveRetentionYears;
        public String description;
        public Integer gracePeriodDays;
        private String[] archiveAfterMonths_type_info = new String[]{'archiveAfterMonths',SOAP_M_URI,null,'1','1','false'};
        private String[] archiveRetentionYears_type_info = new String[]{'archiveRetentionYears',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] gracePeriodDays_type_info = new String[]{'gracePeriodDays',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'archiveAfterMonths','archiveRetentionYears','description','gracePeriodDays'};
    }

    public class Index {
        public MetadataService.IndexField[] fields;
        public String label;
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fields','label'};
    }

    public class IndexField {
        public String name;
        public String sortDirection;
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] sortDirection_type_info = new String[]{'sortDirection',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'name','sortDirection'};
    }

    public class SharingReason extends Metadata {
        public String type = 'SharingReason';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String label;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'label'};
    }

    public class SharingRecalculation {
        public String className;
        private String[] className_type_info = new String[]{'className',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'className'};
    }

    public class ValidationRule extends Metadata {
        public String type = 'ValidationRule';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public Boolean active;
        public String description;
        public String errorConditionFormula;
        public String errorDisplayField;
        public String errorMessage;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] errorConditionFormula_type_info = new String[]{'errorConditionFormula',SOAP_M_URI,null,'1','1','false'};
        private String[] errorDisplayField_type_info = new String[]{'errorDisplayField',SOAP_M_URI,null,'0','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'active','description','errorConditionFormula','errorDisplayField','errorMessage'};
    }
    
}