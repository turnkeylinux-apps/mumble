WEBMIN_FW_TCP_INCOMING = 22 80 443 444 6502 12321 64738

COMMON_OVERLAYS += tkl-webcp
COMMON_CONF += apache-credit tkl-webcp

include $(FAB_PATH)/common/mk/turnkey/apache.mk
include $(FAB_PATH)/common/mk/turnkey/php.mk
include $(FAB_PATH)/common/mk/turnkey.mk
