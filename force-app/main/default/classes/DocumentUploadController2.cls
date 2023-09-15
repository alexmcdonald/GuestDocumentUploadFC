/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
public without sharing class DocumentUploadController2 {


    @AuraEnabled
    public static List<DocumentWrapper> getAllDocuments(String recordId) {
        List<DocumentWrapper> documents = new List<DocumentWrapper>();
        Map<String, List<ContentVersion>> groupedDocuments = groupDocumentsByType(recordId);
        List<qsydApps_AO__Document__mdt> documentTypes = [
                SELECT Id, qsydApps_AO__Category__r.MasterLabel, qsydApps_AO__Document_Name__c, qsydApps_AO__Score__c, qsydApps_AO__Description__c, qsydApps_AO__Icon__c,
                        qsydApps_AO__Accepted_File_Format__c, qsydApps_AO__File_Link__c, qsydApps_AO__Mandatory__c
                FROM qsydApps_AO__Document__mdt
                WHERE qsydApps_AO__Active__c = true
                WITH SECURITY_ENFORCED
                ORDER BY qsydApps_AO__Mandatory__c DESC, qsydApps_AO__Score__c DESC
        ];
        for (qsydApps_AO__Document__mdt docType : documentTypes) {
            DocumentWrapper wrapper = new DocumentWrapper();
            wrapper.document = docType;
            if (groupedDocuments.containsKey(docType.Id)) {
                wrapper.uploadedDocuments.addAll(groupedDocuments.get(docType.Id));
                documents.add(wrapper);
            }
        }
        System.Debug(documents);
        return documents;
    }

    @AuraEnabled
    public static List<DocumentWrapper> getDocuments(String recordId, String category) {
        List<DocumentWrapper> documents = new List<DocumentWrapper>();
        Map<String, List<ContentVersion>> groupedDocuments = groupDocumentsByType(recordId);

        List<qsydApps_AO__Document__mdt> documentTypes = [
                SELECT Id, qsydApps_AO__Category__r.MasterLabel, qsydApps_AO__Document_Name__c, qsydApps_AO__Score__c, qsydApps_AO__Description__c, qsydApps_AO__Icon__c,
                        qsydApps_AO__Accepted_File_Format__c, qsydApps_AO__File_Link__c, qsydApps_AO__Mandatory__c
                FROM qsydApps_AO__Document__mdt
                WHERE qsydApps_AO__Category__r.MasterLabel = :category AND qsydApps_AO__Active__c = true
                WITH SECURITY_ENFORCED
                ORDER BY qsydApps_AO__Mandatory__c DESC, qsydApps_AO__Score__c DESC
        ];
        for (qsydApps_AO__Document__mdt docType : documentTypes) {
            DocumentWrapper wrapper = new DocumentWrapper();
            wrapper.document = docType;
            if (groupedDocuments.containsKey(docType.Id)) {
                wrapper.uploadedDocuments.addAll(groupedDocuments.get(docType.Id));
            }
            documents.add(wrapper);
        }
        return documents;
    }

    @AuraEnabled
    public static void updateDocuments(String documentTypeId, List<String> documentIds, String documentTypeName) {
        System.debug('Document Type Id: '+documentTypeId);
        System.debug('Document Ids: '+documentIds);
        List<ContentVersion> uploadedDocuments = [
                SELECT Id, qsydApps_AO__DocumentTypeId__c
                FROM ContentVersion
                WHERE ContentDocumentId IN :documentIds
                WITH SECURITY_ENFORCED
        ];
        for (ContentVersion doc : uploadedDocuments) {
            doc.qsydApps_AO__DocumentTypeId__c = documentTypeId;
            doc.Document_Type__c = documentTypeName;
        }
        update uploadedDocuments;
    }

    @AuraEnabled
    public static void deleteDocument(String documentId) {
        if (String.isNotBlank(documentId)) {
            List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE Id = :documentId];
            delete documents;
        }
    }

    private static List<String> retrieveRelatedDocumentIds(String recordId) {
        List<ContentDocumentLink> documentLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
                WITH SECURITY_ENFORCED
        ];
        List<String> documentIds = new List<String>();
        for (ContentDocumentLink documentLink : documentLinks) {
            documentIds.add(documentLink.ContentDocumentId);
        }
        return documentIds;
    }

    private static Map<String, List<ContentVersion>> groupDocumentsByType(String recordId) {
        Map<String, List<ContentVersion>> groupedDocuments = new Map<String, List<ContentVersion>>();

        if (String.isNotBlank(recordId)) {
            List<ContentVersion> uploadedDocuments = [
                    SELECT Id, ContentDocumentId, Title, Description,
                            FileType, FileExtension, qsydApps_AO__DocumentTypeId__c, LastModifiedDate
                    FROM ContentVersion
                    WHERE ContentDocumentId IN :retrieveRelatedDocumentIds(recordId) AND qsydApps_AO__DocumentTypeId__c != NULL
                    WITH SECURITY_ENFORCED
            ];
            for (ContentVersion cv : uploadedDocuments) {
                String documentTypeId = cv.qsydApps_AO__DocumentTypeId__c;
                if (!groupedDocuments.containsKey(documentTypeId)) {
                    groupedDocuments.put(documentTypeId, new List<ContentVersion>());
                }
                groupedDocuments.get(documentTypeId).add(cv);
            }
        }
        return groupedDocuments;
    }

    public class DocumentWrapper {
        @AuraEnabled
        public qsydApps_AO__Document__mdt document;

        @AuraEnabled
        public List<ContentVersion> uploadedDocuments;

        public DocumentWrapper() {
            uploadedDocuments = new List<ContentVersion>();
        }
    }

    public static Boolean getCustomLabels() {
        String promptMessage = Label.qsydApps_AO.Cmp_PromptMessage;
        String promptTitle = Label.qsydApps_AO.Cmp_PromptTitle;
        String promptNegativeButtonText = Label.qsydApps_AO.Cmp_PromptNegativeButtonText;
        String promptPositiveButtonText = Label.qsydApps_AO.Cmp_PromptPositiveButtonText;
        return true;
    }

}