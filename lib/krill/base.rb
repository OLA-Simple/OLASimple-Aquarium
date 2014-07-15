module Krill

  module Base

    def debug
      false
    end

    def show

      page = ShowBlock.new.run(&Proc.new)

      # Append page to job state
      append_step( { operation: "display", content: page } )

      # increment pc
      job = Job.find(jid)
      job.pc += 1
      job.save

      if !debug

        # stop and wait for technician to click OK
        mutex().synchronize { thread_status().running = false }
        Thread.stop

        # get technician input and return it
        JSON.parse(job.reload.state, symbolize_names: true).last[:inputs]

      else

        # figure out default technician response
        i = simulated_input_for page
        append_step( { operation: "next", time: Time.now, inputs: i })
        i

      end

    end

    def error e

      append_step( { operation: "error", message: e.to_s, backtrace: e.backtrace[0,10] } )

    end

    private

    def simulated_input_for page

      i = {}

      page.each do |j|

        if j[:input]

          var = j[:input][:var].to_sym
          dft = j[:input][:default]

          if !dft
            if j[:input][:type] == "text"
              dft = "user input string"
            else
              ddt = 0
            end
          end
          i[var] = dft

        elsif j[:select]

          var = j[:select][:var].to_sym
          dft = j[:select][:default]

          if !dft
            dft = 0
          end

          i[var] = j[:select][:choices][dft]

        end

      end

      i[:timestamp] = 1000*Time.now.to_i

      return i

    end

    def append_step s

      job = Job.find(jid)
      state = JSON.parse job.state, symbolize_names: true
      state.push s
      job.state = state.to_json
      job.save 

    end

  end

end