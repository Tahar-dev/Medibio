import { Body, Controller, Get, Post, Put, Param, Delete } from '@nestjs/common';
import { TechnicianService } from './technician.service';
import { LoginDto } from './dto/login.dto';
import { SignUpDto } from './dto/signup.dto';
import { UpdateTechnicianDto } from './dto/update.dto';
import { Technician } from './schemas/technician.schema';

@Controller('technicians')
export class TechnicianController {
  constructor(private technicianService: TechnicianService) {}

  @Post('/signup')
  signUp(@Body() signUpDto: SignUpDto): Promise<{ token: string }> {
    return this.technicianService.signUp(signUpDto);
  }

  @Post('/login')
  login(@Body() loginDto: LoginDto): Promise<{ token: string }> {
    return this.technicianService.login(loginDto);
  }

  @Put('/update/:id')
  updateTechnician(
    @Param('id') id: string,
    @Body() updateTechnicianDto: UpdateTechnicianDto,
  ): Promise<Technician> {
    return this.technicianService.updateTechnician(id, updateTechnicianDto);
  }

  @Put('update-by-name/:name')
  async updateByName(
    @Param('name') name: string,
    @Body() updateDto: UpdateTechnicianDto
  ) {
    return this.technicianService.updateTechnicianByName(name, updateDto);
  }

  @Get('')
  getAllTechnicians(): Promise<Technician[]> {
    return this.technicianService.getAllTechnicians();
  }

  @Get('/get/:id')
  getTechnicianById(@Param('id') id: string): Promise<Technician> {
    return this.technicianService.getTechnicianById(id);
  }

  @Delete('/delete/:id')
  deleteTechnician(@Param('id') id: string): Promise<void> {
    return this.technicianService.deleteTechnicianById(id);
  }

  @Get('/find-tech/:name')
  findByNom(@Param('name') name: string):Promise<Technician> {
    return this.technicianService.findByNom(name);
  }
}
