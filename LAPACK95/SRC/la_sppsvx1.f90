SUBROUTINE SPPSVX1_F95(A, B, X, UPLO, AF, FACT, EQUED, S, FERR, BERR, RCOND, INFO)
!
!  -- LAPACK95 interface driver routine (version 3.0) --
!     UNI-C, Denmark; Univ. of Tennessee, USA; NAG Ltd., UK
!     September, 2000
!
!  .. USE STATEMENTS ..
   USE LA_PRECISION, ONLY: WP => SP
   USE LA_AUXMOD, ONLY: LSAME, ERINFO
   USE F77_LAPACK, ONLY: PPSVX_F77 => LA_PPSVX
!  .. IMPLICIT STATEMENT ..
   IMPLICIT NONE
!  .. SCALAR ARGUMENTS ..
   CHARACTER(LEN=1), INTENT(IN), OPTIONAL :: UPLO, FACT
   CHARACTER(LEN=1), INTENT(INOUT), OPTIONAL :: EQUED
   INTEGER, INTENT(OUT), OPTIONAL :: INFO
   REAL(WP), INTENT(OUT), OPTIONAL :: RCOND, FERR, BERR
!  .. ARRAY ARGUMENTS ..
   REAL(WP), INTENT(INOUT) :: A(:), B(:)
   REAL(WP), INTENT(OUT) :: X(:)
   REAL(WP), INTENT(INOUT), OPTIONAL, TARGET :: AF(:)
   REAL(WP), INTENT(INOUT), OPTIONAL, TARGET :: S(:)
!  .. PARAMETERS ..
   CHARACTER(LEN=8), PARAMETER :: SRNAME = 'LA_PPSVX'
!  .. LOCAL SCALARS ..
   CHARACTER(LEN=1) :: LFACT, LUPLO, LEQUED
   INTEGER :: LINFO, N, NN, ISTAT, ISTAT1, SAF, SS
   REAL(WP) :: LRCOND, MVS, LFERR, LBERR
   COMPLEX(WP) :: WW
!  .. LOCAL POINTERS ..
   INTEGER, POINTER :: IWORK(:)
   REAL(WP),  POINTER :: LS(:)
   REAL(WP),  POINTER :: WORK(:), LAF( :)
!  .. INTRINSIC FUNCTIONS ..
   INTRINSIC PRESENT, SIZE, MINVAL, TINY, REAL, INT, AIMAG
!  .. EXECUTABLE STATEMENTS ..
   LINFO = 0; ISTAT = 0; NN = SIZE(A, 1)
   WW = (-1+SQRT(1+8*REAL(NN,WP)))*0.5; N = INT(WW)
   IF( PRESENT(RCOND) ) RCOND = 1.0_WP
   IF( PRESENT(FACT) )THEN; LFACT = FACT; ELSE; LFACT='N'; END IF
   IF( PRESENT(EQUED) .AND. LSAME(LFACT,'F') )THEN; LEQUED = EQUED
   ELSE; LEQUED='N'; END IF
   IF( PRESENT(AF) )THEN; SAF = SIZE(AF); ELSE; SAF = N*(N+1)/2; END IF
   IF( ( PRESENT(S) ) )THEN; SS = SIZE(S); ELSE; SS = N; END IF
   IF( PRESENT(S) .AND. LSAME(LFACT,'F') .AND. LSAME(LEQUED,'Y') ) THEN
       MVS = MINVAL(S); ELSE; MVS = TINY(1.0_WP); ENDIF
   IF(PRESENT(UPLO))THEN; LUPLO = UPLO; ELSE; LUPLO='U'; END IF
!  .. TEST THE ARGUMENTS
   IF( NN < 0 .OR. AIMAG(WW) /= 0 .OR. REAL(N,WP) /= REAL(WW) ) THEN; LINFO = -1
   ELSE IF( SIZE(B) /= N )THEN; LINFO = -2
   ELSE IF( SIZE(X) /= N )THEN; LINFO = -3
   ELSE IF( .NOT.LSAME(LUPLO,'U') .AND. .NOT.LSAME(LUPLO,'L') )THEN; LINFO = -4
   ELSE IF( SAF /= N*(N+1)/2 ) THEN; LINFO = -5
   ELSE IF( ( .NOT. ( LSAME(LFACT,'F') .OR. LSAME(LFACT,'N') .OR. &
                    LSAME(LFACT,'E') ) ) .OR. &
      ( LSAME(LFACT,'F') .AND. .NOT.PRESENT(AF) ) )THEN; LINFO = -6
   ELSE IF( .NOT.LSAME(LEQUED,'N') .AND. .NOT.LSAME(LEQUED,'Y') )THEN; LINFO = -7
   ELSE IF( SS /= N .OR. LSAME(LFACT,'F') .AND. LSAME(LEQUED,'Y') &
      .AND. MVS  <= 0.0_WP )THEN; LINFO = -8
   ELSE IF ( N > 0 )THEN
      IF( .NOT.PRESENT(AF) ) THEN; ALLOCATE( LAF(N*(N+1)/2), STAT=ISTAT )
      ELSE; LAF => AF; END IF
      IF( ISTAT == 0 )THEN
         IF( .NOT.PRESENT(S) )THEN; ALLOCATE( LS(N), STAT=ISTAT )
         ELSE; LS => S; END IF
      END IF
      IF( ISTAT == 0 ) ALLOCATE(WORK(3*N), IWORK(N), STAT=ISTAT )
      IF( ISTAT == 0 )THEN
         CALL PPSVX_F77( LFACT, LUPLO, N, 1, A, LAF, LEQUED, LS, &
                  B, N, X, N, LRCOND, LFERR, LBERR, WORK, IWORK, LINFO )
      ELSE; LINFO = -100; END IF
      IF( .NOT.PRESENT(S) ) DEALLOCATE( LS, STAT=ISTAT1 )
      IF( .NOT.PRESENT(AF) ) DEALLOCATE( LAF, STAT=ISTAT1 )
      IF( PRESENT(FERR) ) FERR = LFERR
      IF( PRESENT(BERR) ) BERR = LBERR
      IF( PRESENT(RCOND) ) RCOND=LRCOND
      IF( PRESENT(EQUED) .AND. .NOT.LSAME(LFACT,'F') ) EQUED=LEQUED
      DEALLOCATE( WORK, IWORK, STAT=ISTAT1 )
   END IF
   CALL ERINFO( LINFO, SRNAME, INFO, ISTAT )
END SUBROUTINE SPPSVX1_F95
