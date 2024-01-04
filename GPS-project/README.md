# SPP HAS

## Todo

- [ ] 현재 GPS만 가능 -> GAL도 할 수 있게 코드 수정
- [ ] 코드의사거리가 아니라 carrier phase
- [ ] getSatPosVel() 함수 만들어서 위성의 위치와 속도를 구해야함.

## 폴더 구조

```
.
└── datasets
    └── mat
        └── SSRA00EUH0109D.23C.mat
    └── HAS
        └── SSRA00EUH0109D.23C
    └── Indices - DEPRECATE
        ├── SSRA00EUH0109D.23C.CODE_G.txt
        ├── SSRA00EUH0109D.23C.CODE_E.txt
        ├── SSRA00EUH0109D.23C.CLOCK.txt
        └── SSRA00EUH0109D.23C.ORBIT.txt
    └── QM
        └── QSUWN_15032
    └── SP3
        └── igs18300.sp3
    └── EPH
        └── brdc0320.15n
    ├── Index.CODE_G.txt - DEPRECATE
    ├── Index.CODE_E.txt - DEPRECATE
    ├── Index.CLOCK.txt - DEPRECATE
    └── Index.ORBIT.txt - DEPRECATE
└── DEPREACATED - create_indices.m
└── read_has_file.m
└── read_has_mat.m
└── create_mat.m
└── main.m
└── ...
```

## How To Use

### 1. 데이터 mat 파일 생성 -> 데이터가 올바른 폴더에 있는지 확인

```
create_mat.m
```

### 2. run main

```
main.m
```

## Create_indices

“datasets/HAS” 경로에 있는 모든 파일을 읽어들이고, 해당 파일과 이름이 동일한 인덱스파일을 CODE_G,CODE_E,CLOCK,ORBIT 별로 생성.

- HAS 파일의 “>”로 시작하는 헤더 부분을 읽어서 파일 별 데이터의 위치를 저장
  Gw Gs Index Count Interval Mount
  Gps week Gps second 원본 파일 위치 데이터 개수 SSRA00EUH0
- Ex ) SSRA00EUH0109D.23C.ORBIT.txt
  2258,269982.000017,1,52,0,SSRA00EUH0
  2258,269992.000003,180,52,0,SSRA00EUH0
  …
- Index.txt 파일에 각 HAS 파일의 gw,gs Range를 저장
  Gwgs_min gwgs_max File_name
  gwgs gwgs SSRA00EUH0109D.23C.CODE_E.txt

## ReadHAS

Index.~.txt의 gw_gs_range에 포함되는 시간이 있으면, 보정정보 리턴, 없으면 X
CLOCK,ORBIT,CODE_E,CODE_G = ReadHAS(gw,gs)

- Index.CODE_G.txt 에서 gw,gs에 해당하는 indice 파일 읽기
- Indice 파일에서 HAS 파일에서 읽어야할 부분을 획득(예를들어 52번째 줄부터 31개 읽기)
- HAS 파일에서 보정정보 얻어서 리턴
