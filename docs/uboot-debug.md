
SPL and U-Boot phase differernt because [2]


```
SPL and U-Boot does a re-location of address compared to where it is loaded
originally. This step takes place after the DDR size is determined from dt
parsing. So, debugging can be split into either “before re-location” or “after
re-location”. Please refer to the file ‘’doc/README.arm-relocation’’ to see how
to grab the relocation address. ```


```
  sudo apt install gdb-multiarch
```

-> openocd seperat
-> run openocd which opens ports

connect via [1] [3]

```
  gdb-multiarch -ex "target extended-remote localhost:3333" -ex "set arch arm64"
```

load binary with debug information (new symbol table) via [1] [3]

```
  add-symbol-file path/to/u-boot $relocaddr
```

the relocaddr one can get from u-boot itself [1] [3]

```
 => bdinfo
rch_number = XXXXXXXXXX
boot_params = XXXXXXXXXX
DRAM bank   = XXXXXXXXXX
-> start    = XXXXXXXXXX
-> size     = XXXXXXXXXX
ethaddr     = XXXXXXXXXX
ip_addr     = XXXXXXXXXX
baudrate    = XXXXXXXXXX
TLB addr    = XXXXXXXXXX
relocaddr   = 0x8ff08000
	      ^^^^^^^^^^
reloc off   = XXXXXXXXXX
irq_sp	    = XXXXXXXXXX
sp start    = XXXXXXXXXX
FB base     = XXXXXXXXXX
```


[1] https://www.slideshare.net/menonnishanth/openocdk3pptx
https://www.youtube.com/watch?v=n3u3QgnAvV8

[2] https://docs.u-boot.org/en/latest/board/ti/k3.html#common-debugging-environment-openocd

[3] https://github.com/ARM-software/u-boot/blob/master/doc/README.arm-relocation


