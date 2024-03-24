# ฟังก์ชันนี้ดาวน์โหลดโปรแกรม Bitcoin Core เวอร์ชันที่ระบุสำหรับแพลตฟอร์มที่ระบุ
download_bitcoin_core() {
  # นิยามตัวแปรภายในฟังก์ชัน
  # - VERSION: เก็บเวอร์ชันของ Bitcoin Core ที่จะดาวน์โหลด (รับค่าจากพารามิเตอร์ $1)
  # - PLATFORM: เก็บแพลตฟอร์มที่รองรับ (รับค่าจากพารามิเตอร์ $2)
  # - FILENAME: สร้างชื่อไฟล์สำหรับไฟล์ดาวน์โหลด โดยประกอบด้วย เวอร์ชัน-แพลตฟอร์ม.tar.gz
  local VERSION="$1"
  local PLATFORM="$2"
  local FILENAME="bitcoin-$VERSION-$PLATFORM.tar.gz"

  # แสดงข้อความแจ้งการดาวน์โหลด Bitcoin Core เวอร์ชันที่ระบุสำหรับแพลตฟอร์มที่ระบุ
  echo "Downloading Bitcoin Core $VERSION for $PLATFORM..."

  # ใช้คำสั่ง wget เพื่อดาวน์โหลดไฟล์ Bitcoin Core จาก URL ที่สร้างขึ้น
  wget "https://bitcoincore.org/bin/bitcoin-core-$VERSION/$FILENAME"
}

# ฟังก์ชันนี้ดาวน์โหลดไฟล์ SHA256SUMS สำหรับเวอร์ชัน Bitcoin Core ที่ระบุ
download_checksums() {
  # นิยามตัวแปรภายในฟังก์ชัน
  # - VERSION: เก็บเวอร์ชันของ Bitcoin Core ที่จะดาวน์โหลด (รับค่าจากพารามิเตอร์ $1)
  local VERSION="$1"

  # แสดงข้อความแจ้งการดาวน์โหลดไฟล์ SHA256SUMS สำหรับ Bitcoin Core เวอร์ชันที่ระบุ
  echo "Downloading SHA256SUMS for Bitcoin Core $VERSION..."

  # ใช้คำสั่ง wget เพื่อดาวน์โหลดไฟล์ SHA256SUMS จาก URL ที่สร้างขึ้น
  wget "https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS"
}

# ฟังก์ชันนี้ดาวน์โหลดไฟล์ SHA256SUMS.asc สำหรับเวอร์ชัน Bitcoin Core ที่ระบุ
download_signatures() {
  # นิยามตัวแปรภายในฟังก์ชัน
  # - VERSION: เก็บเวอร์ชันของ Bitcoin Core ที่จะดาวน์โหลด (รับค่าจากพารามิเตอร์ $1)
  local VERSION="$1"

  # แสดงข้อความแจ้งการดาวน์โหลดไฟล์ SHA256SUMS.asc สำหรับ Bitcoin Core เวอร์ชันที่ระบุ
  echo "Downloading SHA256SUMS.asc for Bitcoin Core $VERSION..."

  # ใช้คำสั่ง wget เพื่อดาวน์โหลดไฟล์ SHA256SUMS.asc จาก URL ที่สร้างขึ้น
  wget "https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.asc"
}

# ฟังก์ชันนี้ใช้คำนวณ checksum และเปรียบเทียบกับค่าที่อยู่ในไฟล์ SHA256SUMS
checksum_check() {
  # แสดงข้อความแจ้งการตรวจสอบ checksum
  echo "Performing checksum check..."

  # ใช้คำสั่ง sha256sum --ignore-missing --check SHA256SUMS เพื่อคำนวณ checksum
  # ของไฟล์ทั้งหมดที่อยู่ในไฟล์ SHA256SUMS และเปรียบเทียบผลลัพธ์กับค่าที่อยู่ในไฟล์
  sha256sum --ignore-missing --check SHA256SUMS
}

# ฟังก์ชันนี้นำเข้าคีย์สาธารณะ
import_public_keys() {
  # แสดงข้อความแจ้งการนำเข้าคีย์สาธารณะ
  echo "Importing public keys..."
  # ใช้คำสั่ง curl เพื่อดึงข้อมูลจาก URL ของคีย์สาธารณะ และนำมาค้นหา URL สำหรับดาวน์โหลด
  # จากนั้นใช้ grep เพื่อคัดเลือก URL ที่เกี่ยวข้องและนำไปใช้งานกับคำสั่ง curl เพื่อดาวน์โหลดคีย์
  curl -s "https://api.github.com/repositories/355107265/contents/builder-keys" \
     | grep download_url \
     | grep -oE "https://[a-zA-Z0-9./-]+" \
     | while read url; do
       # ใช้คำสั่ง curl เพื่อดึงข้อมูลจาก URL และนำมานำเข้าคีย์โดยใช้ gpg
       curl -s "$url" | gpg --import; done
 }

# ฟังก์ชันนี้ใช้สำหรับการยืนยันลายเซ็น
verify_signatures() {
  # แสดงข้อความแจ้งการยืนยันลายเซ็น
  echo "Verifying signatures..."
  # ใช้ gpg เพื่อทำการยืนยันลายเซ็นของไฟล์ SHA256SUMS.asc
  gpg --verify SHA256SUMS.asc
}

# ฟังก์ชันนี้ใช้สำหรับการติดตั้ง Bitcoin Core
install_bitcoin_core() {
  local VERSION="$1"
  local PLATFORM="$2"

  # แสดงข้อความแจ้งการติดตั้ง Bitcoin Core
  echo "Installing Bitcoin Core $VERSION..."

  # ใช้คำสั่ง tar เพื่อแตกไฟล์ Bitcoin Core
  tar -xvf "bitcoin-$VERSION-$PLATFORM.tar.gz"

  # ใช้ลูปเพื่อติดตั้งไฟล์ทั้งหมดที่อยู่ในไดเรกทอรี bin ของ Bitcoin Core ไปยัง /usr/local/bin/
  for file in "bitcoin-$VERSION/bin/"*; do
    sudo install -m 0755 -o root -g root "$file" "/usr/local/bin/"
  done

  # แสดงเวอร์ชันของ bitcoind หลังจากการติดตั้งเสร็จสมบูรณ์
  bitcoind --version
}

# ฟังก์ชันนี้ใช้สำหรับการทำความสะอาดไฟล์
cleanup_files() {
  local VERSION="$1"
  local PLATFORM="$2"

  # แสดงข้อความแจ้งการทำความสะอาดไฟล์ที่ดาวน์โหลด
  echo "Cleaning up downloaded files..."

  # ใช้คำสั่ง rm เพื่อลบไฟล์ที่ดาวน์โหลดไว้
  rm "bitcoin-$VERSION-$PLATFORM.tar.gz"
  rm "SHA256SUMS"
  rm "SHA256SUMS.asc"
}

# ฟังก์ชันหลักสำหรับการดำเนินการทั้งหมด
main() {
  local VERSION="26.0"
  local PLATFORM=""

  # แสดงข้อความเวอร์ชัน Bitcoin Core ที่สามารถใช้งานได้
  echo "Available Bitcoin Core versions:"
  echo "> Bitcoin Core 26.0"

  # ตรวจสอบและกำหนดแพลตฟอร์มของระบบปฏิบัติการ
  if [[ $(uname -m) == "x86_64" ]]; then
    PLATFORM="x86_64-linux-gnu"
  elif [[ $(uname -m) == "arm"* ]]; then
    PLATFORM="aarch64-linux-gnu"
  else
    echo "Unsupported CPU architecture."
    exit 1
  fi

  # เรียกใช้ฟังก์ชันต่าง ๆ เพื่อดำเนินการตามขั้นตอนการติดตั้ง Bitcoin Core
  download_bitcoin_core "$VERSION" "$PLATFORM"
  download_checksums "$VERSION"
  download_signatures "$VERSION"
  checksum_check
  import_public_keys
  verify_signatures
  install_bitcoin_core "$VERSION" "$PLATFORM"
  cleanup_files "$VERSION" "$PLATFORM"

  # แสดงข้อความเมื่อการติดตั้งเสร็จสมบูรณ์
  echo "Bitcoin Core setup completed successfully."
}

# เรียกใช้ฟังก์ชันหลัก
main
