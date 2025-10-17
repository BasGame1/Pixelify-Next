
import re

class GMSFlagDecoder:
    def __init__(self):
        self.decoded_cache = {}
        self.LATEST_GMS_PATTERNS = {
            "4535": "GMS_Core",
            "4536": "GMS_Extended",
            "4537": "GMS_Advanced",
            "4538": "GMS_Store",
            "4539": "GMS_Experimental",
            "4540": "GMS_AI_ML",
            "4541": "GMS_Security",
            "4542": "GMS_Privacy",
            "4543": "GMS_Performance",
            "4544": "GMS_Network",
            "4545": "GMS_Sync",
            "4546": "GMS_Update",
            "4547": "GMS_Backup",
            "4548": "GMS_Location",
            "4549": "GMS_Media"
        }
        self.LATEST_SERVICE_IDS = {
            "71": "Core_Services",
            "72": "Sync_Services",
            "73": "Update_Services",
            "74": "Security_Services",
            "75": "Network_Services",
            "76": "AI_ML_Services",
            "77": "Privacy_Services",
            "78": "Performance_Services",
            "79": "Media_Services",
            "80": "Location_Services",
            "81": "Backup_Services",
            "82": "Analytics_Services"
        }
        self.LATEST_FEATURE_TYPES = {
            "0000": "Core_Base",
            "0001": "Auto_Enable",
            "0002": "Manual_Control",
            "0003": "Smart_Default",
            "0004": "Conditional_Enable",
            "0005": "Progressive_Enable",
            "0006": "Rollback_Protection",
            "0007": "A_B_Testing",
            "0008": "Feature_Flag",
            "0009": "Remote_Config",
            "1000": "Performance_Base",
            "1001": "Speed_Optimization",
            "1002": "Memory_Optimization",
            "1003": "Battery_Optimization",
            "1004": "Network_Optimization",
            "1005": "Storage_Optimization",
            "1006": "CPU_Optimization",
            "1007": "GPU_Optimization",
            "1008": "Cache_Optimization",
            "1009": "Thread_Optimization",
            "2000": "Security_Base",
            "2001": "Encryption_Enable",
            "2002": "Authentication_Enable",
            "2003": "Authorization_Enable",
            "2004": "Integrity_Check",
            "2005": "Malware_Protection",
            "2006": "Phishing_Protection",
            "2007": "Data_Protection",
            "2008": "Privacy_Controls",
            "2009": "Compliance_Features",
            "3000": "AI_ML_Base",
            "3001": "Machine_Learning",
            "3002": "Neural_Networks",
            "3003": "Natural_Language",
            "3004": "Computer_Vision",
            "3005": "Recommendation_Engine",
            "3006": "Predictive_Analytics",
            "3007": "Pattern_Recognition",
            "3008": "Automated_Reasoning",
            "3009": "Knowledge_Graph",
            "4000": "Network_Base",
            "4001": "HTTP_2_Enable",
            "4002": "QUIC_Enable",
            "4003": "IPv6_Enable",
            "4004": "5G_Optimization",
            "4005": "WiFi_Optimization",
            "4006": "Mobile_Data_Optimization",
            "4007": "Bandwidth_Management",
            "4008": "Latency_Optimization",
            "4009": "Connection_Pooling",
            "5000": "Sync_Base",
            "5001": "Real_Time_Sync",
            "5002": "Batch_Sync",
            "5003": "Incremental_Sync",
            "5004": "Conflict_Resolution",
            "5005": "Offline_Sync",
            "5006": "Cross_Device_Sync",
            "5007": "Selective_Sync",
            "5008": "Background_Sync",
            "5009": "Priority_Sync",
            "6000": "Update_Base",
            "6001": "Auto_Update",
            "6002": "Incremental_Update",
            "6003": "Delta_Update",
            "6004": "Rolling_Update",
            "6005": "Canary_Update",
            "6006": "Staged_Update",
            "6007": "Emergency_Update",
            "6008": "Scheduled_Update",
            "6009": "Conditional_Update",
            "7000": "Media_Base",
            "7001": "Video_Optimization",
            "7002": "Audio_Optimization",
            "7003": "Image_Optimization",
            "7004": "Codec_Optimization",
            "7005": "Streaming_Optimization",
            "7006": "Compression_Optimization",
            "7007": "Quality_Adaptation",
            "7008": "Bandwidth_Adaptation",
            "7009": "Device_Adaptation",
            "8000": "Location_Base",
            "8001": "GPS_Optimization",
            "8002": "WiFi_Location",
            "8003": "Cell_Location",
            "8004": "Indoor_Location",
            "8005": "Geofencing",
            "8006": "Activity_Recognition",
            "8007": "Motion_Detection",
            "8008": "Context_Awareness",
            "8009": "Privacy_Preserving_Location",
            "9000": "Privacy_Base",
            "9001": "Data_Minimization",
            "9002": "Anonymization",
            "9003": "Pseudonymization",
            "9004": "Consent_Management",
            "9005": "Data_Retention",
            "9006": "Access_Control",
            "9007": "Audit_Logging",
            "9008": "Data_Portability",
            "9009": "Right_to_Deletion"
        }

    def decode_flag(self, flag_name, package_name=None):
        try:
            cache_key = f"{package_name}:{flag_name}"
            if cache_key in self.decoded_cache:
                return self.decoded_cache[cache_key]

            if not flag_name:
                return "Empty_Flag"

            decoded = self.decode_using_latest_general_schema(flag_name)

            self.decoded_cache[cache_key] = decoded
            return decoded
        except Exception as e:
            return f"Error_{flag_name[:10]}"

    def decode_using_latest_general_schema(self, flag_name):
        if re.match(r"45\d{6}", flag_name):
            return f"Chrome_Experiment_{flag_name[-4:]}"
        if re.match(r"453\d{4}", flag_name):
            return f"GMS_Feature_{flag_name[-4:]}"
        if re.match(r"10\d{4}", flag_name):
            return f"Framework_{flag_name[-4:]}"
        if re.match(r"20\d{3}", flag_name):
            return f"Google_App_{flag_name[-3:]}"
        if re.match(r"30\d{2}", flag_name):
            return f"System_UI_{flag_name[-2:]}"
        if re.match(r"9\d{2}", flag_name):
            return f"Debug_{flag_name[-2:]}"
        if flag_name.endswith("000"):
            return f"Performance_{flag_name[:-3]}"
        if flag_name.endswith("999"):
            return f"Beta_{flag_name[:-3]}"
        if re.match(r"453[5-9]\d{4}", flag_name):
            return f"Phixit_{flag_name[-4:]}"
        if flag_name.startswith("recovered_flag_"):
            return f"Recovered_{flag_name[15:]}"
        if flag_name.startswith("unnamed_flag_"):
            return f"Unnamed_{flag_name[13:]}"
        if re.match(r"\d+", flag_name):
            return f"Legacy_{flag_name}"
        return flag_name

if __name__ == '__main__':
    import sys
    decoder = GMSFlagDecoder()
    flag_name = sys.argv[1]
    package_name = sys.argv[2] if len(sys.argv) > 2 else None
    print(decoder.decode_flag(flag_name, package_name))
