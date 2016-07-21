#!/bin/bash
if [ -z "$BENCHMARKS" ] ; then
  BENCHMARKS="cpu-methods matrix-methods string-methods class_cpu class_cpu-cache class_memory"
fi

if [ -z $NUM_WORKERS ] ; then
  NUM_WORKERS=1
fi

if [ -z $TIMEOUT ] ; then
  TIMEOUT=10
fi

COMMON="$NUM_WORKERS -t $TIMEOUT --metrics-brief --times -Y /out.yml"

function include_comma {
  if [ "$need_comma" = true ] ; then
    echo ","
  else
    need_comma=true
  fi
}

function get_category {
  if [ $1 == "stream" ] ; then
    category="memory"
  elif [ $1 == *"matrix"* ] ; then
    category="memory"
  elif [ $1 == *"memory"* ] ; then
    category="memory"
  else
    category="cpu"
  fi
}

need_comma=false
category="foo"

echo "["

for bench in $BENCHMARKS ; do
  if [[ $bench == "cpu-methods" ]] ; then
    include_comma
    for method in ackermann bitops callfunc cdouble cfloat clongdouble correlate crc16 dither djb2a double euler explog fft fibonacci float fnv1a gamma gcd gray hamming hanoi hyperbolic idct int128 int64 int32 int16 int8 int128float int128double int128longdouble int64float int64double int64longdouble int32float int32double int32longdouble jenkin jmp ln2 longdouble loop matrixprod nsqrt omega parity phi pi pjw prime psi queens rand rand48 rgb sdbm sieve sqrt trig union zeta ; do
       stress-ng --cpu-method $method --cpu $COMMON &> /dev/null
       /postprocess.py cpu $method
       if [ "$method" != "zeta" ] ; then
         # print comma for all but the last (zeta)
         echo ","
       fi
    done
  elif [[ $bench == "matrix-methods" ]] ; then
    include_comma
    for method in add copy div frobenius hadamard mean mult prod sub trans ; do
       stress-ng --matrix-method $method --matrix $COMMON &> /dev/null
       /postprocess.py matrix $method
       if [ "$method" != "trans" ] ; then
         echo ","
       fi
    done
  elif [[ $bench == "string-methods" ]] ; then
    include_comma
    for method in index rindex strcasecmp strcat strchr strcoll strcmp strcpy strlen strncasecmp strncat strncmp strrchr strxfrm ; do
       stress-ng --str-method $method --str $COMMON &> /dev/null
       /postprocess.py string $method
       if [ "$method" != "strxfrm" ] ; then
         echo ","
       fi
    done
  elif [[ $bench == "class_cpu" ]] ; then
    include_comma
    stress-ng --class cpu --exclude matrix,context,atomic --sequential $COMMON &> /dev/null
    /postprocess.py cpu
  elif [[ $bench == "class_memory" ]] ; then
    include_comma
    stress-ng --class memory --exclude bsearch,hsearch,lsearch,qsort,wcs,tsearch,stream,numa,atomic,str --sequential $COMMON &> /dev/null
    /postprocess.py memory
  elif [[ $bench == "class_cpu-cache" ]] ; then
    include_comma
    stress-ng --class cpu-cache --exclude bsearch,hsearch,lsearch,matrix,qsort,malloc,str,stream,memcpy,wcs,tsearch,af-alg,cpu,crypt,longjmp,numa,opcode,qsort,vecmath,lockbus --sequential $COMMON &> /dev/null
    /postprocess.py cpu-cache
  else
    # if we didn't get "special" id, then we assume it's a regular stressor
    include_comma
    stress-ng "--$bench" $COMMON &> /dev/null
    get_category $bench
    /postprocess.py $category
  fi
done

echo "]"
