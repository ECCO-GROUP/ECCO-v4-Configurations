!> \file dictionary_m.f90
!! \brief Module file for dictionary_t

!> Dictionary type that uses strings for the keys and values
!!
!! Design:
!!  - djb2 hash function (D. J. Bernstein, see http://www.cse.yorku.ca/~oz/hash.html)
!!  - The strings are all "character(len=:), allocatable" variables
!!  - There is no linked list nor pointers, only allocatable arrays for the dynamic data structure
!!  - set rewrites existing entries without complaining

      module dictionary_m
        implicit none
        private
        public :: dictionary_t, fileHash

!> Single entry in the dictionary
        type entry_t
          character(len=:), allocatable :: key
          !character(len=:), allocatable :: value
          integer, allocatable :: val1
!          logical, allocatable :: val2
!          integer, allocatable :: val3
        end type entry_t

!> A bucket contains several entries
        type bucket_t
          type(entry_t), allocatable :: entries(:)
          integer :: current_size = 0
          integer :: current_idx = 0
         contains
          procedure :: find
        end type bucket_t

!> The dictionary contains dict_size buckets (defined at run time)
        type dictionary_t
          type(bucket_t), allocatable :: buckets(:)
          integer :: dict_size = 0
         contains
          procedure :: djb2
          procedure :: set
          procedure :: get1
!          procedure :: get2
!          procedure :: get3
          procedure :: init
          procedure :: show
          procedure :: fclose
        end type dictionary_t

        integer, parameter :: BUCKET_EMPTY = -2
        integer, parameter :: BUCKET_ENTRY_NOT_FOUND = -4

        type(dictionary_t) :: fileHash

      contains

!> djb2 hash function
!!
!! \param this the dictionary_t object
!! \param s a string
!!
!! \return the hash value between 0 and dict_size-1
      function djb2(this, s) result(r)
        class(dictionary_t), intent(in) :: this
        character(len=*), intent(in) :: s
        integer :: r
        integer :: i, l

        l = len(s)
        r = 5381
        do i = 1, l
           r = r*33 + ichar(s(i:i))
        end do
        r = modulo(r, this%dict_size)
      end function djb2

!> Add or replace an entry in the dictionary
!!
!! \param this the dictionary_t object
!! \param k the key
!! \param v the value
!      subroutine set(this, k, v1, v2, v3)
      subroutine set(this, k, v1)
        class(dictionary_t), intent(inout) :: this
        character(len=*), intent(in) :: k
        !character(len=*), intent(in) :: v
        integer, intent(in) :: v1
!        logical, intent(in) :: v2
!        integer, intent(in) :: v3

        type(bucket_t) :: tmp_bucket
        integer :: h, i, b_idx

        h = this%djb2(k) + 1
        b_idx = this%buckets(h)%find(k)

        if (b_idx == BUCKET_EMPTY) then
          ! allocate bucket for 1 entry
          ! also, means we can take the first entry
          allocate(this%buckets(h)%entries(1))
          this%buckets(h)%current_size = 1
          this%buckets(h)%current_idx = 1
          b_idx = 1
          this%buckets(h)%entries(1)%key = trim(k)
          !this%buckets(h)%entries(1)%value = trim(v)
          this%buckets(h)%entries(1)%val1 = v1
!          this%buckets(h)%entries(1)%val2 = v2
!          this%buckets(h)%entries(1)%val3 = v3
          ! the values are registered, exit
          !write(*,*) 'set: allocate space for ', trim(k),'  ',v
          return
        end if

        if (b_idx == BUCKET_ENTRY_NOT_FOUND) then
          ! copy and grow bucket entries

          allocate(tmp_bucket%entries(this%buckets(h)%current_size + 1))
          tmp_bucket%current_size = this%buckets(h)%current_size + 1
          tmp_bucket%current_idx = this%buckets(h)%current_idx + 1

          do i = 1, this%buckets(h)%current_size
            tmp_bucket%entries(i)%key = this%buckets(h)%entries(i)%key
            tmp_bucket%entries(i)%val1=this%buckets(h)%entries(i)%val1
!            tmp_bucket%entries(i)%val2=this%buckets(h)%entries(i)%val2
!            tmp_bucket%entries(i)%val3=this%buckets(h)%entries(i)%val3
          end do

          deallocate(this%buckets(h)%entries)
          allocate(this%buckets(h)%entries, source=tmp_bucket%entries)
          deallocate(tmp_bucket%entries)

          this%buckets(h)%current_size = tmp_bucket%current_size
          this%buckets(h)%current_idx = tmp_bucket%current_idx
          b_idx = this%buckets(h)%current_idx
          !write(*,*) 'set: BUCKET_ENTRY_NOT_FOUND '
        end if

        if (b_idx > 0) then
          this%buckets(h)%entries(b_idx)%key = k
          this%buckets(h)%entries(b_idx)%val1 = v1
!          this%buckets(h)%entries(b_idx)%val2 = v2
!          this%buckets(h)%entries(b_idx)%val3 = v3
          !write(*,*) 'set: b_idx > 0 ', trim(k),v
        end if
      end subroutine set

!> Initialize a dictionary object
!!
!! \param this the dictionary_t object
!! \param dict_size the size of the hash table
      subroutine init(this, dict_size)
        class(dictionary_t), intent(out) :: this
        integer, intent(in) :: dict_size

        allocate(this%buckets(dict_size))
        this%dict_size = dict_size
      end subroutine init

!> Display the content of a dictionary
!!
!! \param this the dictionary_t object
      subroutine show(this)
        class(dictionary_t), intent(in) :: this
        integer :: i, j, s
        integer :: n

        n = 0
        do i = 1, this%dict_size
          s = this%buckets(i)%current_idx
          if (s > 0) then
            write(*,*) 'bucket   : ', i, ' size ', s
            do j = 1, s
              write(*,*) 'key      : ', this%buckets(i)%entries(j)%key
              write(*,*) 'value 1  : ', this%buckets(i)%entries(j)%val1
!              write(*,*) 'value 2  : ', this%buckets(i)%entries(j)%val2
!              write(*,*) 'value 3  : ', this%buckets(i)%entries(j)%val3
            end do
          end if
        end do
      end subroutine show

      subroutine fclose(this)
#ifdef INTEL_COMMITQQ
        use ifcore
#endif
        class(dictionary_t), intent(in) :: this
        integer :: i, j, s
        integer :: n,ios

        n = 0
        do i = 1, this%dict_size
          s = this%buckets(i)%current_idx
          if (s > 0) then
            do j = 1, s
              if (this%buckets(i)%entries(j)%val1 .gt. 0) then
#ifdef INTEL_COMMITQQ
                if(.not. commitqq(this%buckets(i)%entries(j)%val1))
     &            write(*,*) 'dictionary_m::fclose: Failed to commit ',
     &            trim(this%buckets(i)%entries(j)%key)
#endif
                close(this%buckets(i)%entries(j)%val1,iostat=ios)
!                write(*,*) 'Closed file ', 
!     &                     trim(this%buckets(i)%entries(j)%key), 
!     &            ' unit was ', this%buckets(i)%entries(j)%val1,
!     &            ' with status ',  ios
              end if
            end do
          end if
        end do
        !deallocate(this%buckets(h)%entries)
      end subroutine fclose

!> Find the "in-bucket" index for a given key
!!
!! Negative return values correspond to module-defined return codes.
!!
!! \param this the bucket_t object
!! \param k the key
!!
!! \return the index (1-based) of the key in the bucket or a return code
      function find(this, k) result(r)
        class(bucket_t), intent(in) :: this
        character(len=*), intent(in) :: k
        integer :: r
        integer :: i

        if (this%current_size == 0) then
          r = BUCKET_EMPTY
          return
        end if

        r = BUCKET_ENTRY_NOT_FOUND
        do i = 1, this%current_size
          if (this%entries(i)%key == trim(k)) then
            r = i
            exit
          end if
        end do
      end function find

!> Fetch an entry in the dictionary.
!!
!! \param this the dictionary_t object
!! \param k the key
!!
!! \return the value if found, an empty string else
      function get1(this, k) result(r)
        class(dictionary_t), intent(in) :: this
        character(len=*), intent(in) :: k
        !character(len=:), allocatable :: r
        integer, allocatable :: r
        integer :: h, b_idx

        h = this%djb2(k) + 1
        b_idx = this%buckets(h)%find(k)

        if ( (b_idx == BUCKET_EMPTY) .or.
     &       (b_idx == BUCKET_ENTRY_NOT_FOUND) ) then
          r = -999
          return
        end if

        if (b_idx>0) then
          r = this%buckets(h)%entries(b_idx)%val1
        end if
      end function get1

!      function get2(this, k) result(r)
!        class(dictionary_t), intent(in) :: this
!        character(len=*), intent(in) :: k
!        !character(len=:), allocatable :: r
!        logical, allocatable :: r
!        integer :: h, b_idx
!
!        h = this%djb2(k) + 1
!        b_idx = this%buckets(h)%find(k)
!
!        if ( (b_idx == BUCKET_EMPTY) .or.
!     &       (b_idx == BUCKET_ENTRY_NOT_FOUND) ) then
!          r = .false.
!          return
!        end if
!
!        if (b_idx>0) then
!          r = this%buckets(h)%entries(b_idx)%val2
!        end if
!      end function get2

!      function get3(this, k) result(r)
!        class(dictionary_t), intent(in) :: this
!        character(len=*), intent(in) :: k
!        !character(len=:), allocatable :: r
!        integer, allocatable :: r
!        integer :: h, b_idx
!
!        h = this%djb2(k) + 1
!        b_idx = this%buckets(h)%find(k)
!
!        if ( (b_idx == BUCKET_EMPTY) .or.
!     &       (b_idx == BUCKET_ENTRY_NOT_FOUND) ) then
!          r = .false.
!          return
!        end if
!
!        if (b_idx>0) then
!          r = this%buckets(h)%entries(b_idx)%val3
!        end if
!      end function get3

      end module dictionary_m
