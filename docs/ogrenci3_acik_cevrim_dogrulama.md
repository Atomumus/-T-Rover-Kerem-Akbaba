# Ogrenci 3 - Acik Cevrim Simulasyonu ve Steady-State Dogrulama

## Senden istenen is nedir?

Ogrenci 3'un gorevi, Ogrenci 2 tarafindan MATLAB'a aktarilan Sorensen ODE
modelinin matematiksel olarak dengede calisip calismadigini gostermektir.
Bu kisimda PID kontrolor, Simulink blok diyagrami veya yemek senaryosu
kullanilmaz.

Yapilacak test:

1. Model bazal/aclik baslangic kosullarindan baslatilir.
2. Dis insulin girisi sifir yapilir: `u_ins = 0`.
3. Yemek/karbonhidrat bozucu etkisi sifir yapilir: `meal_input = 0`.
4. Sistem `ode45` ile acik cevrim calistirilir.
5. Kan sekeri `GH`, plasma insulin `IH` ve glukagon `Gamma` degerlerinin
   baslangic degerinden sapmadan duz cizgi gibi kalip kalmadigi incelenir.

Bu test basariliysa modelin bazal denge noktasi dogru kurulmus demektir ve
Ogrenci 4 modeli Simulink'e tasimaya daha guvenli sekilde devam edebilir.

## Hazirlanan dosyalar

- `matlab/sorensen_parameters.m`: Model parametreleri ve bazal denge
  degerleri.
- `matlab/sorensen_initial_conditions.m`: 22 elemanli baslangic vektoru.
- `matlab/sorensen_odes.m`: 22 ODE'lik Sorensen sistemi.
- `matlab/validate_sorensen_open_loop.m`: Ogrenci 3'un calistiracagi acik
  cevrim steady-state dogrulama scripti.

## MATLAB'da nasil calistirilir?

MATLAB'da proje klasorunu ac ve su komutu calistir:

```matlab
run('matlab/validate_sorensen_open_loop.m')
```

Script sunlari otomatik yapar:

- Baslangic noktasinda `dy/dt` degerinin sifira yakin olup olmadigini kontrol
  eder.
- 0-300 dakika arasi `ode45` simulasyonu yapar.
- Tum durum degiskenleri icin baslangic, final, mutlak sapma ve yuzde sapma
  tablosu olusturur.
- Ana klinik ciktilar icin kabul kriteri uygular:
  - `GH`, `IH`, `Gamma` final yuzde hatasi <= %1
  - `GH`, `IH`, `Gamma` maksimum yuzde sapmasi <= %1
  - normalize baslangic turevi <= `1e-6`

## Uretilecek ciktilar

Script calisinca `results/` klasorune su dosyalar kaydedilir:

- `student3_open_loop_summary.csv`: Rapor icin tablo.
- `student3_open_loop_results.mat`: MATLAB workspace sonucu.
- `student3_open_loop_validation.png`: Rapor/sunum icin grafik.

## Rapora yazilabilecek kisa yorum

Acik cevrim dogrulama testinde Sorensen modeli bazal aclik kosullarindan
baslatilmis, sisteme dis insulin veya yemek bozucu etkisi uygulanmamistir.
Baslangic noktasinda ODE turevlerinin sifira yakin olmasi ve 300 dakikalik
`ode45` simulasyonu boyunca `GH`, `IH` ve `Gamma` ciktilarinin bazal degerleri
etrafinda sabit kalmasi, modelin steady-state kosulunu sagladigini gosterir.
Bu sonuc, kapali cevrim PID ve yemek senaryolarina gecmeden once matematiksel
modelin denge noktasinin dogru kuruldugunu dogrular.
