# Inject AWS IAM Auth to Confluent image
FROM confluentinc/cp-schema-registry:7.9.1

USER root
ADD --chown=appuser:appuser aws-msk-iam-auth-2.3.2-all.jar /usr/share/java/cp-base-new/
ADD --chown=appuser:appuser aws-msk-iam-auth-2.3.2-all.jar /usr/share/java/schema-registry/
ADD --chown=appuser:appuser aws-msk-iam-auth-2.3.2-all.jar /usr/share/java/aws-msk-iam/

ENV SCHEMA_REGISTRY_KAFKASTORE_SECURITY_PROTOCOL="SASL_SSL"
ENV SCHEMA_REGISTRY_KAFKASTORE_SASL_MECHANISM="AWS_MSK_IAM"
ENV SCHEMA_REGISTRY_KAFKASTORE_SASL_JAAS_CONFIG="software.amazon.msk.auth.iam.IAMLoginModule required;"
ENV SCHEMA_REGISTRY_KAFKASTORE_SASL_CLIENT_CALLBACK_HANDLER_CLASS="software.amazon.msk.auth.iam.IAMClientCallbackHandler"
ENV CLASSPATH=/usr/share/java/aws-msk-iam/*
USER appuser

EXPOSE 8081
