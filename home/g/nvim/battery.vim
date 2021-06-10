function! battery#update(job_id, data, event) abort
  if a:event == 'stdout' && a:data[0] != ''
    let g:battery = a:data[0]
  endif
endfunction

function! s:watch_callback(...) abort
  let s:callbacks = { 'on_stdout': function('battery#update') }
  let s:battery_job = jobstart(['bash', '-c', 'acpi | grep -oP "(\d+)%" | tr -d "\n"'], s:callbacks)
  let s:timer = timer_start(
        \ g:battery#update_interval,
        \ function('s:watch_callback')
        \)
endfunction

function! battery#watch() abort
  if exists('s:timer')
    call timer_stop(s:timer)
  endif
  let s:timer = timer_start(0, function('s:watch_callback'))
endfunction

function! battery#unwatch() abort
  if exists('s:timer')
    call timer_stop(s:timer)
    unlet s:timer
  endif
endfunction
