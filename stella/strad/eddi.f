      SUBROUTINEFeau(incnd,Kntold)
      IMPLICITREAL*8(A-H,O-Z)
      PARAMETER(NVARS=3)
      include '../obj/nfreq_and_mzone.inc'
      PARAMETER(NYDIM=(NVARS+2*NFREQ)*Mzon,MAXDER=4)
      Parameter(Is=5)
      PARAMETER(NZ=3000000)
      Parameter(Nstage=28,Natom=15)
      PARAMETER(KOMAX=80)
      LogicalLSYSTEM
      Parameter(LSystem=.FALSE.)
      Parameter(Pi=3.1415926535897932d+00,hPlanc=1.0545716280D-27,Cs=2.9979245800D+10,Boltzk=1.3806504000D-16,Avogar=6.0221417900D+2
     *3,AMbrun=1.6605387832D-24,AMelec=9.1093821500D-28,echarg=4.8032042700D-10,CG=6.6742800000D-08,CMS=1.9884000000D+33,RSol=6.9551
     *000000D+10,ULGR=1.4000000000D+01,UPURS=1.0000000000D+07,ULGPU=7.0000000000D+00,ULGEU=1.3000000000D+01,UPC=3.0856776000D+18,UTP
     *=1.0000000000D+05,URHO=1.0000000000D-06,CARAD=7.5657680191D-15,CSIGM=5.6704004778D-05,ERGEV=1.6021764864D-12,GRADeV=1.16045052
     *85D+04,RADC=7.5657680191D-02,CTOMP=4.0062048575D-01,CCAPS=2.6901213726D+01,CCAPZ=9.8964034725D+00)
      IntegerZn(Natom),ZnCo(Natom+1)
      DimensionAZ(Natom)
      Common/AZZn/AZ,Zn,ZnCo
      Common/NiAdap/tday,t_eve,XNifor(Mzon),AMeveNi,KNadap
      LOGICALFRST
      Parameter(Mfreq=130)
      Common/Kmzon/km,kmhap,Jac,FRST
      COMMON/STCOM1/t,H,HMIN,HMAX,EPS,N,METH,KFLAG,JSTART
      COMMON/YMAX/YMAX(NYDIM)
      COMMON/YSTIF/Y(NYDIM,MAXDER+1)
      COMMON/HNUSED/HUSED,NQUSED,NFUN,NJAC,NITER,NFAIL
      COMMON/HNT/HNT(7)
      PARAMETER(DELTA=1.d-05)
      PARAMETER(LICN=4*NZ,LIRN=2*NZ)
      LogicalNEEDBR
      COMMON/STJAC/THRMAT,HL,AJAC(LICN),IRN(LIRN),ICN(LICN),WJAC(NYDIM),FSAVE(NYDIM*2),IKEEP(5*NYDIM),IW(8*NYDIM),IDISP(11),NZMOD,NE
     *EDBR
      LOGICALCONV,CHNCND,SCAT,SEP
      COMMON/CUTOFF/FLOOR(NVARS+1),Wacc(NVARS+1),FitTau,TauTol,Rvis,CONV,CHNCND,SCAT,SEP
      LogicalLTHICK
      COMMON/THICK/LTHICK(Nfreq,Mzon)
      COMMON/CONVEC/UC(Mzon),YAINV(Mzon)
      COMMON/RAD/EDDJ(Mzon,Nfreq),EDDH(Mzon),HEDD(Nfreq),HEDRAD,CLIGHT,CKRAD,UFREQ,CFLUX,CCL,CLUM,CLUMF,CIMP,NTHICK(NFREQ),NTHNEW(NF
     *REQ),bolM,NCND,KRAD,NFRUS
      LOGICALEDTM
      COMMON/RADOLD/HEDOLD,HINEDD,EDTM
      Common/newedd/EddN(Mzon,Nfreq),HEdN(Nfreq),tfeau
      Common/oldedd/EddO(Mzon,Nfreq),HEdo(Nfreq),trlx
      Common/cnlast/Cnlast
      Common/Dhap/DHaphR(Mzon,Nfreq)
      COMMON/BAND/FREQ(NFREQ+1),FREQMN(NFREQ),WEIGHT(130),HAPPAL(NFREQ),HAPABSRON(NFREQ),HAPABS(NFREQ),DLOGNU(NFREQ)
      PARAMETER(NFRMIN=Nfreq/2)
      IntegerdLfrMax
      Common/observer/wH(Mfreq),cH(Mfreq),zerfr,Hcom(Mfreq),Hobs(Mfreq),freqob(Mfreq),dLfrMax
      Parameter(NP=15+15-1)
      Common/famu/fstatic(0:NP+1,Nfreq),fobs_corr(0:NP+1,Mfreq),fcom(0:NP+1,Mfreq),amustatic(0:NP+1)
      Common/rays/Pray(0:Np+1),fout(0:NP+1,Mfreq),abermu(0:NP+1),NmuNzon
      COMMON/LIM/Uplim,Haplim
      COMMON/AMM/DMIN,DM(Mzon),DMOUT,AMINI,AM(Mzon),AMOUT
      COMMON/Centr/RCE,Nzon
      Common/InEn/AMHT,EBurst,tBurst,tbeght
      COMMON/RADPUM/AMNI,XMNi,XNi,KmNick
      COMMON/RADGAM/FJgam(Mzon,2),toldg,tnewg
      COMMON/RADGlg/FJglog(Mzon,2)
      COMMON/CHEM/CHEM0(Mzon),RTphi(0:Mzon+1),EpsUq
      COMMON/REGIME/NREG(Mzon)
      doubleprecisionNRT
      COMMON/AQ/AQ,BQ,DRT,NRT
      COMMON/AZNUC/ACARB,ZCARB,ASI,ZSI,ANI,ZNI,QCSI,QSINI
      COMMON/QNRGYE/QNUC,RGASA,YELECT
      COMMON/CKN1/CK1,CK2,CFR,CRAP,CRAOLD
      LOGICALEVALJA,OLDJAC,BADSTE
      COMMON/EVAL/EVALJA,BADSTE,OLDJAC
      LogicalRadP
      COMMON/RadP/RadP
      COMMON/ARG/TP,PL,CHEM,LST,KENTR,JURS
      COMMON/RESULT/P,Egas,Sgas,ENG,CAPPA,PT,ET,ST,ENGT,CAPT,NZR
      COMMON/ABUND/XYZA,Yat(Natom)
      COMMON/AZ/AS,ZS,SCN
      COMMON/STR/PPL,EPL,SPL,ENGPL,CAPPL,CP,GAM,DA,DPE,DSE,DSP,BETgas
      COMMON/XELECT/XE,XET,XEPL,PE,Ycomp
      COMMON/URScap/Tpsqrt,Psicap,Scap,ScapT,ScapPl,ZMean,YZMean,ZMT,ZMPl,YZMT,YZMPl
      COMMON/BURNCC/CC,CCTP,CCPL,YDOT
      COMMON/ABarr/YABUN(Natom,Mzon)
      COMMON/UNSTL/UL,UPRESS,UE,UEPS,UCAP,UTIME,UV,UFLUX,UP
      COMMON/TAIL/KTAIL
      COMMON/UNINV/UPI,UEI
      COMMON/UNBSTL/UR,UM,UEPRI,ULGP,ULGE,ULGV,ULGTM,ULGEST,ULGFL,ULGCAP,ULGEPS
      Parameter(tret=1.d0/3.d0)
      COMMON/CONUR/EIT,DST,BBRCNR(5)
      COMMON/BAL/EL(MAXDER+1),YENTOT(MAXDER+1),ETOT0,ELVOL,ELSURF,ELTOT,TPSURF,HOLDBL,ELOST,EKO,RADBEG
      common/NSTEP/NSTEP,NDebug,MAXER,IOUT,NOUT
      common/CREAD/TAUOLD,NSTMAX,MBATCH,MAXORD
      common/debug/LfrDebug,Nperturb,Kbad
      REAL*8TPMAX(MAXDER+1),TQ(4)
      COMMON/TAU/TAU(Mzon+1),FLUX(Mzon)
      common/tauubvri/tauU(Mzon),tauB(Mzon),tauV(Mzon),tauR(Mzon),tauI(Mzon)
      COMMON/PHOT/XJPH,DMPH,RPH,TPH,PLPH,VPH,CHEMPH,GRVPH,HP,JPH
      PARAMETER(NFUNC=6)
      REAL*4WORK(Mzon+2,NFREQ),WRK(Mzon,4)
      REAL*8WRKX(Mzon),WORKX(Mzon+2)
      COMMON/STEPD/WRKX,WORKX,TPHOT,TEFF,WORK,WRK,NPHOT,NZM
      PARAMETER(TMCRIT=1.D-6,TPNSE=5.D0,EPGROW=0.02D0)
      Common/RUTP/Ry(Mzon),Uy(Mzon),Ty(Mzon),Press(Mzon),Rho(Mzon)
      COMMON/TOO/TOO,KO,KNTO,TO(KOMAX),STO(KOMAX),NTO(KOMAX)
      Parameter(Lcurdm=1000)
      RealTcurv
      IntegerNFRUSED
      REAL*8Flsave
      Common/Curve/tcurv(8,Lcurdm),Depos(Lcurdm),Flsave(MFREQ+1,Lcurdm),NFRUSED(Lcurdm),Lsaved
      LOGICALBEGRUN
      Common/BEGR/BEGRUN
      CHARACTER*80Model,Sumprf,Sumcur,Depfile,Flxfile
      COMMON/Files/Model,Sumprf,Sumcur,Depfile,Flxfile
      CHARACTER*1app
      LogicalGivdtl
      Common/ABGrap/NSTA,NSTB,TcurA,TcurB,Givdtl
      REAL*8MBOL,MU,MB,MV,MR,MI,MBOL1
      COMMON/COLOR/MBOL,MU,MB,MV,MR,MI,UMB,BMV,MBOL1,LubvU,LubvB,LubvV,LubvR,LubvI,Lyman
      COMMON/DETAIL/QRTarr(Mzon),UUarr(Mzon),ArrLum(Mzon),Acc(Mzon)
      Common/XYZ/XA,YA,URM
      Integersm_device
      Character*40chalab
      DimensionRMPray(Mzon)
      Dimensiondtau(Mzon,0:Np)
      Real*4xipl(0:Np),fspl(0:Np),ftst(0:Np),fmin,fmax
      DimensionZR(0:Mzon)
      DimensionRM(0:Mzon),umr(0:Mzon)
      DimensionRHS(2*Mzon+2)
      DimensionFRADK(Mzon),FJLfr(Mzon),FHWork(Mzon),FJWork(Mzon)
      DimensionFS(0:NP+1,Mzon),Amu(0:NP+1,0:Mzon)
      DimensionFD(0:NP,Mzon)
      DimensionFSdir(0:NP+1,Mzon),FDdir(0:NP,Mzon)
      DimensionKz(0:NP+1),MsF(0:NP+1),Msh(0:NP+1),Krowst(0:NP+1)
      DimensionNMU(Mzon)
      DimensionFDLEFT(Nfreq)
      DimensionHAPW(Mzon,Nfreq)
      DimensionHAPabW(Mzon,Nfreq)
      DimensionChim(Mzon),Chiabm(Mzon),ChiabZ(Mzon)
      DimensionChiZ(Mzon)
      doubleprecisionxnu,xnuMax
      Realtime1,time2
      Realtm1,tm2
      Parameter(Nchn=4)
      LogicaltretL
      Common/FRAD/FRADJ(Mzon,Nfreq),FRADH(Mzon,Nfreq)
      Common/FSFD/FS,FD
      BLACK(Lbl,Tpbl)=(exp(-(FREQMN(Lbl)/Tpbl)))/(1.d0-(exp(-(FREQMN(Lbl)/Tpbl))))
      BLACKD(Lbl,Tpbl)=(FREQMN(Lbl)/Tpbl)*(exp(-(FREQMN(Lbl)/Tpbl)))/(1.d0-(exp(-(FREQMN(Lbl)/Tpbl))))**2
      fblack(fr,Tpbl)=(exp(-(fr/Tpbl)))/(1.d0-(exp(-(fr/Tpbl))))
      FJr(km,L)=Y(NVARS*NZON+(NZON-NCND)*(L-1)-NCND+Km,1)
      Ip=0
      kzer=0
      nrdial=0
      tretL=.false.
      tfeau=t
      Rout=Ry(Nzon)
      If(incnd.GT.0)then
      Rcore=Ry(incnd)
      else
      Rcore=Ry(1)
      Rcore=Ry(Kmnick)
      endif
      zerfr=log(freqob(1))+1.d0/dlognu(1)
      NPE=15*nint((Rout-Rcore)/Rout)
      NPE=min(NPE,15)
      NPE=max(NPE,2)
      NPC=15+15-NPE
      Pray(0)=0.D0
      Pray(NP+1)=ROUT
      DPE=(Rout-Rcore)/DBLE(NPE+1)
      DPC=Rcore/DBLE(NPC)
      DO09997i=1,Npc
      Pray(i)=Pray(i-1)+DPC
09997 CONTINUE
      DO09994i=Npc+1,Np
      Pray(i)=Pray(i-1)+DPE
09994 CONTINUE
      DO09991K=incnd+1,Nzon
      IF(K.GT.1)RM(K)=0.5D0*(Ry(K)+Ry(K-1))
      PL=rho(K)
      Tp=Ty(K)
      DO09988i=1,Natom
      Yat(i)=YABUN(i,K)
09988 CONTINUE
      RADP=.FALSE.
      CALLURSOS
      kmhap=K
      CALLHAPPA
      DO09985Lfr=1,NFRUS
      HAPW(K,Lfr)=HAPPAL(Lfr)
      HAPabW(K,Lfr)=HAPabs(Lfr)
09985 CONTINUE
09991 CONTINUE
      If(incnd.GT.1)then
      RM(incnd)=0.5D0*(Ry(incnd)+Ry(incnd-1))
      else
      RM(1)=0.5D0*Ry(1)
      RM(0)=0.025*Ry(1)
      endif
      DO09982K=incnd,Nzon
      IF(K.GT.1)umr(K)=0.5D0*(uy(K)+uy(K-1))
09982 CONTINUE
      umr(1)=0.5D0*uy(1)
      umr(0)=0.025*uy(1)
      NEEDBR=.True.
      DO09979Lfr=1,NFRUS
      Knth=INCND
      If(Knth.EQ.0)Then
      FDLEFT(Lfr)=0.D0
      Rleft=0.d0
      else
      If(Knth.GT.Nzon-3)Then
      tretL=.true.
      DO09976k=incnd+1,Nzon
      FJLfr(k)=black(Lfr,Ty(K))
      FradK(k)=tret*FJLfr(k)
      FradH(k,Lfr)=0.d0
      FradJ(k,Lfr)=FJLfr(k)
      EddN(k,Lfr)=tret
09976 CONTINUE
      HEdN(lfr)=0.5d0
      GOTO09979
      endif
      If(Knth.EQ.incnd)Then
      Rleft=Rcore
      else
      Rleft=Ry(Knth)
      endif
      PL=rho(Knth)
      Tp=Ty(Knth)
      DO09973i=1,Natom
      Yat(i)=YABUN(i,Knth)
09973 CONTINUE
      RADP=.FALSE.
      CALLURSOS
      kmhap=Knth
      CALLOPACIT
      CAP1=CAPPA
      Tp1=Tp
      PL=rho(Knth+1)
      Tp=Ty(Knth+1)
      DO09970i=1,Natom
      Yat(i)=YABUN(i,Knth+1)
09970 CONTINUE
      CALLURSOS
      kmhap=Knth+1
      CALLOPACIT
      FLCOR1=((Ry(Knth)*Tp1)**4-(Ry(Knth)*Tp)**4)*Tp1**4/(CAP1*(DM(Knth)+DM(Knth+1))*(Tp1**4+Tp**4))
      FLCOR2=((Ry(Knth)*Tp1)**4-(Ry(Knth)*Tp)**4)*Tp**4/((CAPPA*(DM(Knth)+DM(Knth+1))+0.d0*Ry(Knth)**2)*(Tp1**4+Tp**4))
      FL1=FLCOR1+FLCOR2
      FDLEFT(Lfr)=FL1*blacKD(Lfr,(0.5D0*(Tp+Tp1)))*CAPPA/(1.d0*(0.5D0*(Tp+Tp1))**4*Rleft**2*HAPW(Knth+1,Lfr))
      endif
      KLASTS=Nzon
      DO09967Ip=NP,0,-1
      Kzer=Nzon
09964 IF(.NOT.(Pray(Ip).LT.RM(Kzer).AND.Kzer.GT.Knth))GOTO09963
      Kzer=Kzer-1
      GOTO09964
09963 CONTINUE
      Nrdial=max(Nzon-Kzer,1)
      DO09961K=Kzer+1,Nzon
      Amu(Ip,K)=SQRT(1.D0-(Pray(Ip)/RM(K))**2)
09961 CONTINUE
      Amu(Ip,Kzer)=0.d0
      K=Kzer
      If(K.LT.KlastS)then
      DO09958IK=K+1,KlastS
      NMU(IK)=Ip
09958 CONTINUE
      KlastS=K
      Elseif(K.GT.0)then
      Nmu(K)=Npc
      Endif
      Kz(Ip)=Kzer
09967 CONTINUE
      Krow=0
      Krowst(Np)=0
      Jac=0
      DO09955Ip=NP,0,-1
      Kzer=Kz(Ip)
09955 CONTINUE
      KZrowsc=Krow
      If(Scat)then
      NEQ=KZrowsc+(Nzon-Knth)
      else
      Write(*,*)' notScat Eddi'
      NEQ=krow
      endif
      If(KNadap.EQ.2.or.KNadap.EQ.3)then
      write(*,*)' freqs not geom. progr.!! '
      stop52
      endif
      DO09952Kpl=Nzon,incnd+1,-1
      DO09949Ip=Nmu(Kpl),0,-1
      fr0=freqob(Lfr)
      chiab=HAPabW(Kpl,Lfr)
      chiex=HAPW(Kpl,Lfr)
      dtau(Kpl,Ip)=(Amu(Ip,Kpl)*RM(Kpl)-Amu(Ip,Kpl-1)*RM(Kpl-1))*chiex*rho(Kpl)
      If(Scat.AND.Nstep.GT.1.AND.Kpl.GT.Kntold)then
      fdirsumm=(chiab*fblack(fr0,Ty(Kpl))+(chiex-chiab)*FJr(Kpl,Lfr))/HapW(Kpl,Lfr)*(1.d0-exp(-dtau(Kpl,Ip)/2.d0))
      else
      fdirsumm=fblack(fr0,Ty(Kpl))*(1.d0-exp(-dtau(Kpl,Ip)/2.d0))
      endif
      tauz=dtau(Kpl,Ip)/2.d0
      K=Kpl-1
09946 IF(.NOT.(K.GT.Kz(Ip)))GOTO09945
      duz=Amu(Ip,Kpl)*umr(Kpl)-Amu(Ip,K)*umr(K)
      fr0=freqob(Lfr)*(1.d0+duz/clight)
      fr0log=log(fr0)
      xnu=(zerfr-fr0log)*dlognu(1)
      Lfr0=min(Nfrus,max(int(xnu),1))
      wfr0=xnu-dble(Lfr0)
      chiab=HAPabW(K,Lfr0)*(1.d0-wfr0)+HAPabW(K,min(Nfrus,Lfr0+1))*wfr0
      chiex=HAPW(K,Lfr0)*(1.d0-wfr0)+HAPW(K,min(Nfrus,Lfr0+1))*wfr0
      dtau(K,Ip)=(Amu(Ip,K)*RM(K)-Amu(Ip,K-1)*RM(K-1))*chiex*rho(K)
      If(Scat.AND.Nstep.GT.1.AND.K.GT.Kntold)then
      fdirsumm=fdirsumm+(chiab*fblack(fr0,Ty(K))+(chiex-chiab)*(FJr(K,Lfr0)*(1.d0-wfr0)+FJr(K,min(Nfrus,Lfr0+1))*wfr0))/chiex*exp(-t
     *auz)*(1.d0-exp(-dtau(K,Ip)))
      else
      fdirsumm=fdirsumm+fblack(fr0,Ty(K))*exp(-tauz)*(1.d0-exp(-dtau(K,Ip)))
      endif
      tauz=tauz+dtau(K,Ip)
      K=K-1
      GOTO09946
09945 CONTINUE
      if(K.EQ.Kz(ip).AND.tauz.LT.1.d+02)then
09943 IF(.NOT.(tauz.LT.1.d+02.AND.K.LT.Nzon))GOTO09942
      K=K+1
      duz=Amu(Ip,Kpl)*umr(Kpl)+Amu(Ip,K)*umr(K)
      fr0=freqob(Lfr)*(1.d0+duz/clight)
      fr0log=log(fr0)
      xnu=(zerfr-fr0log)*dlognu(1)
      Lfr0=min(Nfrus,max(int(xnu),1))
      wfr0=xnu-dble(Lfr0)
      chiab=HAPabW(K,Lfr0)*(1.d0-wfr0)+HAPabW(K,min(Nfrus,Lfr0+1))*wfr0
      chiex=HAPW(K,Lfr0)*(1.d0-wfr0)+HAPW(K,min(Nfrus,Lfr0+1))*wfr0
      dtau(K,Ip)=(Amu(Ip,K)*RM(K)-Amu(Ip,K-1)*RM(K-1))*chiex*rho(K)
      If(Scat.AND.Nstep.GT.1.AND.K.GT.Kntold)then
      tauz=tauz+dtau(K,Ip)
      fdirsumm=fdirsumm+(chiab*fblack(fr0,Ty(K))+(chiex-chiab)*(FJr(K,Lfr0)*(1.d0-wfr0)+FJr(K,min(Nfrus,Lfr0+1))*wfr0))/chiex*exp(-t
     *auz)*(1.d0-exp(-dtau(K,Ip)))
      else
      tauz=tauz+dtau(K,Ip)
      fdirsumm=fdirsumm+fblack(fr0,Ty(K))*exp(-tauz)*(1.d0-exp(-dtau(K,Ip)))
      endif
      GOTO09943
09942 CONTINUE
      endif
      If(Kpl.GT.kz(ip))then
      FSdir(Ip,Kpl)=fdirsumm
      endif
09949 CONTINUE
09999 continue
09952 CONTINUE
      DO09940Kpl=incnd+1,Nzon
      DO09937Ip=Nmu(Kpl),0,-1
      Ki=max(Kpl,kz(Ip)+1)
      fr0=freqob(Lfr)
      chiab=HAPabW(Ki,Lfr)
      chiex=HAPW(Ki,Lfr)
      dtau(Ki,Ip)=(Amu(Ip,Ki)*RM(Ki)-Amu(Ip,Ki-1)*RM(Ki-1))*chiex*rho(Ki)
      If(Scat.AND.Nstep.GT.1.AND.Ki.GT.Kntold)then
      fdirsumm=(chiab*fblack(fr0,Ty(Ki))+(chiex-chiab)*FJr(Ki,Lfr))/HapW(Ki,Lfr)*(1.d0-exp(-dtau(Ki,Ip)/2.d0))
      else
      fdirsumm=fblack(fr0,Ty(Ki))*(1.d0-exp(-dtau(Ki,Ip)/2.d0))
      endif
      tauz=dtau(Ki,Ip)/2.d0
      K=Ki
09934 IF(.NOT.(K.LT.Nzon))GOTO09933
      K=K+1
      duz=Amu(Ip,K)*umr(K)-Amu(Ip,Ki)*umr(Ki)
      fr0=freqob(Lfr)*(1.d0+duz/clight)
      fr0log=log(fr0)
      xnu=(zerfr-fr0log)*dlognu(1)
      Lfr0=min(Nfrus,max(int(xnu),1))
      wfr0=xnu-dble(Lfr0)
      chiab=HAPabW(K,Lfr0)*(1.d0-wfr0)+HAPabW(K,min(Nfrus,Lfr0+1))*wfr0
      chiex=HAPW(K,Lfr0)*(1.d0-wfr0)+HAPW(K,min(Nfrus,Lfr0+1))*wfr0
      dtau(K,Ip)=(Amu(Ip,K)*RM(K)-Amu(Ip,K-1)*RM(K-1))*chiex*rho(K)
      If(Scat.AND.Nstep.GT.1.AND.K.GT.Kntold)then
      fdirsumm=fdirsumm+(chiab*fblack(fr0,Ty(K))+(chiex-chiab)*(FJr(K,Lfr0)*(1.d0-wfr0)+FJr(K,min(Nfrus,Lfr0+1))*wfr0))/chiex*exp(-t
     *auz)*(1.d0-exp(-dtau(K,Ip)))
      else
      fdirsumm=fdirsumm+fblack(fr0,Ty(K))*exp(-tauz)*(1.d0-exp(-dtau(K,Ip)))
      endif
      tauz=tauz+dtau(K,Ip)
      GOTO09934
09933 CONTINUE
      If(Kpl.GT.kz(ip))then
      FDdir(Ip,Kpl)=(FSdir(Ip,Kpl)-fdirsumm)/2.d0
      FSdir(Ip,Kpl)=(FSdir(Ip,Kpl)+fdirsumm)/2.d0
      endif
09937 CONTINUE
      DO09931Ip=0,NP
      xipl(Ip)=(Ip)
      If(Kpl.LE.kz(ip))then
      ftst(Ip)=ftst(max(0,Ip-1))
      fspl(Ip)=fspl(max(0,Ip-1))
      endif
09931 CONTINUE
09998 continue
09940 CONTINUE
      DO09928Ip=0,Np
      fcom(Ip,Lfr)=2.d0*FSdir(Ip,Nzon)
09928 CONTINUE
      DO09925K=incnd+1,Nzon
      If(K.LE.Knth)Then
      FJLfr(k)=black(Lfr,Ty(K))
      FradK(k)=tret*FJLfr(k)
      Fradh(k,Lfr)=0.d0
      EddN(k,Lfr)=tret
      Else
      FJLfr(K)=0.D0
      FRADH(K,Lfr)=0.D0
      FRADK(K)=0.D0
      FHWork(K)=0.D0
      FJWork(K)=0.D0
      DO09922Ipnmu=NMU(K)-1,0,-1
      FJLfr(K)=FJLfr(K)+(FSdir(Ipnmu,K)+FSdir(Ipnmu+1,K))*(Amu(Ipnmu,K)-Amu(Ipnmu+1,K))
      IF(K.LT.Nzon)then
      if(Hapw(K,Lfr)*rho(k)*(Ry(K+1)-Ry(K)).LT.Fittau/Tautol)then
      FRADH(K,Lfr)=FRADH(K,Lfr)+(FDdir(Ipnmu,K)+FDdir(Ipnmu+1,K))*(Amu(Ipnmu,K)**2-Amu(Ipnmu+1,K)**2)
      endif
      Endif
      FRADK(K)=FRADK(K)+(FSdir(Ipnmu,K)+FSdir(Ipnmu+1,K))*(Amu(Ipnmu,K)**3-Amu(Ipnmu+1,K)**3)
09922 CONTINUE
      FJLfr(K)=FJLfr(K)+2.D0*FSdir(NMU(K),K)*Amu(NMU(K),K)
      IF(K.LT.Nzon)then
      if(Hapw(K,Lfr)*rho(k)*(Ry(K+1)-Ry(K)).LT.Fittau/Tautol)then
      FRADH(K,Lfr)=(FRADH(K,Lfr)+2.D0*FDdir(NMU(K),K)*Amu(NMU(K),K)**2)
      endif
      Endif
      FRADK(K)=FRADK(K)+2.D0*FSdir(NMU(K),K)*Amu(NMU(K),K)**3
      FJLfr(K)=FJLfr(K)*0.5D0
      IF(K.LT.Nzon)FRADH(K,Lfr)=FRADH(K,Lfr)/4.D0
      FRADK(K)=FRADK(K)/6.D0
      IF(ABS(FJLFR(K)).GT.1.d-50)THEN
      EddN(K,Lfr)=FRADK(K)/FJLfr(K)
      ELSE
      EddN(K,LFR)=TRET
      ENDIF
      endif
      FradJ(K,Lfr)=FJLfr(K)
09925 CONTINUE
      FRADH(Nzon,Lfr)=0.D0
      DO09919Ipnmu=NMU(Nzon)-1,0,-1
      FRADH(Nzon,Lfr)=FRADH(Nzon,Lfr)+(FSdir(Ipnmu,Nzon)+FSdir(Ipnmu+1,Nzon))*(Amu(Ipnmu,Nzon)**2-Amu(Ipnmu+1,Nzon)**2)
09919 CONTINUE
      FRADH(Nzon,Lfr)=0.25d0*(FRADH(Nzon,Lfr)+2.d0*FSdir(NMU(Nzon),Nzon)*Amu(NMU(Nzon),Nzon)**2)
      RADH=0.D0
      DO09916Ipnmu=NMU(Nzon)-1,0,-1
      RADH=RADH+(FSdir(Ipnmu,Nzon)+FSdir(Ipnmu+1,Nzon))*(Amu(Ipnmu,Nzon)**2-Amu(Ipnmu+1,Nzon)**2)
09916 CONTINUE
      RADH=RADH+2.d0*FSdir(NMU(Nzon),Nzon)*Amu(NMU(Nzon),Nzon)**2
      If(ABS(FJLFR(Nzon)).GT.1.d-50)then
      HEdN(Lfr)=RADH/(4.D0*FJLfr(Nzon))
      else
      HEdN(LFR)=0.5D0
      endif
      IF(Lfr.EQ.LubvB)EDDH(Nzon)=HEdN(Lfr)
09979 CONTINUE
      If(incnd.EQ.ncnd.and..not.tretL)then
      Lfr=20
      fr0=freqob(Lfr)*(1.d0-uy(Nzon)/clight)
      fr0log=log(fr0)
      zerfr=log(freqob(1))+1.d0/dlognu(1)
      xnu=(zerfr-fr0log)*dlognu(1)
      Lfr0=int(xnu)
      dLfrMax=Lfr-Lfr0
      if(Nfrus+dLfrMax.GT.Nfreq)then
      endif
      DO09913Lfr=1,Nfrus+dLfrMax
      DO09910Ipnmu=0,NP
      duz=-Amu(Ipnmu,Nzon)*uy(Nzon)
      fr0=freqob(Lfr)*(1.d0+duz/clight)
      fr0log=log(fr0)
      xnu=(zerfr-fr0log)*dlognu(1)
      Lfr0=max(int(xnu),1)
      if(Lfr.GT.dLfrMax)then
      if(Lfr0.LT.1)stop' Lfr0 must be >= 1 in feau for Lfr>dLfrMax'
      wfr0=(freqob(Lfr0+1)-fr0)/(freqob(Lfr0+1)-freqob(Lfr0))
      fout(Ipnmu,Lfr)=exp(log(max(fcom(Ipnmu,Lfr0),1.d-50))*wfr0+log(max(fcom(Ipnmu,min(Nfrus,Lfr0+1)),1.d-50))*(1.d0-wfr0))
      else
      if(Lfr0.GE.1)then
      wfr0=(freqob(Lfr0+1)-fr0)/(freqob(Lfr0+1)-freqob(Lfr0))
      fout(Ipnmu,Lfr)=exp(log(max(fcom(Ipnmu,Lfr0),1.d-50))*wfr0+log(max(fcom(Ipnmu,min(Nfrus,Lfr0+1)),1.d-50))*(1.d0-wfr0))
      endif
      endif
09910 CONTINUE
09913 CONTINUE
      DO09907Ip=0,NP
      abermu(Ip)=Amu(Ip,Nzon)+(uy(Nzon)/clight)*(1.d0-Amu(Ip,Nzon)**2)
09907 CONTINUE
      DO09904Lfr=1,Nfrus+dLfrMax
      Hobs(Lfr)=0.D0
      Hcomov=0.d0
      DO09901Ipnmu=NMU(Nzon)-1,0,-1
      Hobs(Lfr)=Hobs(Lfr)+(fout(Ipnmu,Lfr)+fout(Ipnmu+1,Lfr))*(abermu(Ipnmu)**2-abermu(Ipnmu+1)**2)
      if(Lfr.LE.Nfrus)Hcomov=Hcomov+(fcom(Ipnmu,Lfr)+fcom(Ipnmu+1,Lfr))*(amu(Ipnmu,Nzon)**2-amu(Ipnmu+1,Nzon)**2)
09901 CONTINUE
      if(Lfr.LE.Nfrus)Hcomov=0.125d0*(Hcomov+fcom(NMU(Nzon),Lfr)*amu(NMU(Nzon),Nzon)**2)
      Hobs(Lfr)=0.125d0*(Hobs(Lfr)+fout(NMU(Nzon),Lfr)*abermu(NMU(Nzon))**2)
09904 CONTINUE
      Hnorm=0.d0
      tlum=0.d0
      DO09898L=1,NFRUS+dLfrMax
      Hnorm=Hnorm+Hobs(L)*WEIGHT(L)
      if(L.LE.Nfrus)tlum=tlum+fradH(Nzon,L)*WEIGHT(L)*(1.d0+(uy(Nzon)/clight)*(1.d0+EddN(Nzon,L))/HEdn(L))
09898 CONTINUE
      DO09895Lfr=1,Nfrus+dLfrMax
      if(Hnorm.GT.0.d0)Hobs(Lfr)=tlum/Hnorm*Hobs(Lfr)
      fr0=freqob(Lfr)*(1.d0-uy(Nzon)/clight)
      fr0log=log(fr0)
      xnu=(zerfr-fr0log)*dlognu(1)
      Lfr0=min(Nfreq-1,Nfrus,max(int(xnu),1))
      Lfr0=int(xnu)
      if(Lfr0.GT.1)then
      wfr0=(freqob(Lfr0+1)-fr0)/(freqob(Lfr0+1)-freqob(Lfr0))
      wfrlog=(log(freqob(Lfr0+1))-fr0log)*(-dlognu(1))
      wH(Lfr)=wfrlog
      If(abs(FradH(Nzon,min(Lfr0+1,Nfrus))*Hobs(Lfr)*FradH(Nzon,Lfr0)).GT.1.d-50**3.and.FradH(Nzon,min(Lfr0+1,Nfrus)).GT.0.d0.and.Fr
     *adH(Nzon,Lfr0).GT.0.d0)then
      cH(Lfr)=Hobs(Lfr)/exp((1.d0-wH(Lfr))*log(FradH(Nzon,min(Lfr0+1,Nfrus)))+wH(Lfr)*log(FradH(Nzon,Lfr0)))
      else
      cH(Lfr)=cH(max(1,Lfr-1))
      endif
      else
      if(FradH(Nzon,Lfr).GT.1.d-50)then
      cH(Lfr)=Hobs(Lfr)/FradH(Nzon,Lfr)
      else
      cH(Lfr)=1.d0
      endif
      wH(Lfr)=1.d0
      endif
09895 CONTINUE
      endif
      RETURN
      END
