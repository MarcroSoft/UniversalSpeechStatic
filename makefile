# Makefile til statisk UniversalSpeech med -Os og sections

CC      = gcc
AR      = ar
ARFLAGS = rcs

# Optimering og sektioner (samme spare-flags som resten af stakken)
#
# -Wno-unused-parameter: com-interface.c og sapi.c implementerer COM-
# vtabeller, hvor signaturen er dikteret af graensefladen (this, riid,
# lcid ...). Ubrugte parametre er en foelge af det, ikke en fejl, og de
# kan ikke fjernes. Slaaet fra her i forkens egen makefile, saa upstream-
# filerne ikke skal fyldes med 42 (void)-kast, der ville stoeje ved
# fremtidige rebases. Alle oevrige -Wall/-Wextra-advarsler er RETTET i
# koden - bygget skal vaere helt tavst.
CFLAGS_COMMON = -std=gnu99 -Wall -Wextra -Wno-unused-parameter -Os \
	-ffunction-sections -fdata-sections \
	-fno-ident -fno-asynchronous-unwind-tables

# Her kan du styre debug/release
ifdef DEBUG
    CFLAGS  = $(CFLAGS_COMMON) -g -DDEBUG
    SUFFIX  = d
else
    CFLAGS  = $(CFLAGS_COMMON) -DNDEBUG
    SUFFIX  =
endif

# Biblioteksnavn
LIBNAME  = libUniversalSpeechStatic$(SUFFIX).a
OBJDIR   = obj$(SUFFIX)

# Kilder. Udeladt med vilje:
#  - src/java/      (JNI-binding, ubrugt i statisk C-brug)
#  - screenReaderAPICompat.c (dll-eksportfacade for gamle ScreenReaderAPI.dll,
#    intet internt kalder den, og den hardcoder __declspec(dllexport))
SRCS_CORE = $(wildcard src/*.c)
SRCS_WIN  = $(filter-out src/windows/screenReaderAPICompat.c,$(wildcard src/windows/*.c))

SRCS = $(SRCS_CORE) $(SRCS_WIN)
OBJS = $(patsubst src/%.c,$(OBJDIR)/%.o,$(SRCS))

.PHONY: all clean

all: $(LIBNAME)

$(LIBNAME): $(OBJS)
	$(AR) $(ARFLAGS) $@ $^

# Generel regel for objektfiler
$(OBJDIR)/%.o: src/%.c $(wildcard include/*.h) $(wildcard src/*.h) $(wildcard src/windows/*.h)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -Iinclude -Isrc -c $< -o $@

clean:
	@rm -rf $(OBJDIR) $(LIBNAME)
