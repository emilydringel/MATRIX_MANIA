; ModuleID = 'example.c'
source_filename = "example.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4 -- this is x
  %3 = alloca [8 x i32], align 16 -- allocating space for the array
  store i32 0, i32* %1, align 4
  store i32 7, i32* %2, align 4
  %4 = getelementptr inbounds [8 x i32], [8 x i32]* %3, i64 0, i64 0 -- gets address of arr[0]
  store i32 2, i32* %4, align 4 -- adding first element to array
  %5 = getelementptr inbounds i32, i32* %4, i64 1 -- gets address of arr[1]
  store i32 3, i32* %5, align 4
  %6 = getelementptr inbounds i32, i32* %5, i64 1
  store i32 5, i32* %6, align 4
  %7 = getelementptr inbounds i32, i32* %6, i64 1
  %8 = load i32, i32* %2, align 4 -- loading x to do arithmetic
  %9 = add nsw i32 %8, 3
  store i32 %9, i32* %7, align 4
  %10 = getelementptr inbounds i32, i32* %7, i64 1
  store i32 3, i32* %10, align 4
  %11 = getelementptr inbounds i32, i32* %10, i64 1
  store i32 4, i32* %11, align 4
  %12 = getelementptr inbounds i32, i32* %11, i64 1
  store i32 5, i32* %12, align 4
  %13 = getelementptr inbounds i32, i32* %12, i64 1
  store i32 6, i32* %13, align 4
  %14 = getelementptr inbounds [8 x i32], [8 x i32]* %3, i32 0, i32 0 -- getting arr[0] again
  call void @printm(i32* %14)
  ret i32 0
}

declare void @printm(i32*) #1

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
