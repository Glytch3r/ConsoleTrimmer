import os
import uuid
import xml.etree.ElementTree as ET

root_dir = "media"
file_guid_table = os.path.join(root_dir, "fileGuidTable.xml")

tree = ET.parse(file_guid_table)
root = tree.getroot()

for files_tag in root.findall("files"):
    path_tag = files_tag.find("path")
    guid_tag = files_tag.find("guid")
    if path_tag is None or guid_tag is None:
        continue

    file_path = os.path.join(path_tag.text)
    if not os.path.isfile(file_path):
        print(f"Missing file: {file_path}")
        continue

    new_guid = str(uuid.uuid4())
    guid_tag.text = new_guid

    try:
        sub_tree = ET.parse(file_path)
        sub_root = sub_tree.getroot()
        m_guid_tag = sub_root.find("m_GUID")
        if m_guid_tag is not None:
            m_guid_tag.text = new_guid
            sub_tree.write(file_path, encoding="utf-8", xml_declaration=True)
        else:
            print(f"No <m_GUID> found in {file_path}")
    except ET.ParseError:
        print(f"Error parsing {file_path}")

tree.write(file_guid_table, encoding="utf-8", xml_declaration=True)
print("All GUIDs replaced successfully.")
