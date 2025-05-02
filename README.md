# TestPr

1. Клонування репозиторію
Відкрийте Terminal.
Виконайте команду:
git clone https://github.com/IvanProze/TestPr.git
Це створить локальну копію всіх файлів та історії комітів репозиторію
GitHub Docs

2. Відкриття проєкту в Xcode

Перейдіть у каталог із репозиторієм:
cd TestPr/testPr
Відкрийте робочий простір (workspace), щоб підключити всі Swift‑пакети:
Подвійний клік на файл testPr.xcodeproj/project.xcworkspace
– або в Terminal:
open testPr.xcodeproj/project.xcworkspace
3.
При відкритті .xcworkspace Xcode автоматично спробує завантажити й інтегрувати усі залежності, вказані в Package.resolved (Alamofire, Kingfisher, Rick‑and‑Morty API) 
Apple Developer
.
– Якщо автоматичний процес не спрацював, можна оновити пакети вручну:
File → Swift Packages → Update to Latest Package Versions
